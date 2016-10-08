#
# Copyright:: Copyright (c) 2015 The Inviqa Group Limited
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This software makes sure that SSL_CERT_FILE environment variable is pointed
# to the bundled CA certificates that ship with omnibus. With this, Chef
# tools can be used with https URLs out of the box.

name "hem"
default_version "master"

source :git => "https://github.com/inviqa/hem"

if windows?
  dependency "ruby-windows"
else
  dependency "ruby"
  dependency "rubygems"
end

dependency "rb-readline"

dependency "cacerts"
dependency "openssl-customization"

# The devkit has to be installed after openssl-customization so the
# file it installs gets patched.
dependency "ruby-windows-devkit" if windows?

# Pre-compile lib dependencies
dependency "dep-selector-libgecode"
dependency "dep-selector-libgecode-10" unless windows?
dependency "nokogiri"
dependency "bundler"
dependency "appbundler"
dependency "hem-cacerts"

build do
  env = with_standard_compiler_flags(with_embedded_path)
  env['HEM_BUILD'] = '1'

  if windows?
    # Normally we would symlink the required unix tools.
    # However with the introduction of git-cache to speed up omnibus builds,
    # we can't do that anymore since git on windows doesn't support symlinks.
    # https://groups.google.com/forum/#!topic/msysgit/arTTH5GmHRk
    # Therefore we copy the tools to the necessary places.
    # We need tar for 'knife cookbook site install' to function correctly
    {
      'tar.exe'          => 'bsdtar.exe',
      'libarchive-2.dll' => 'libarchive-2.dll',
      'libexpat-1.dll'   => 'libexpat-1.dll',
      'liblzma-1.dll'    => 'liblzma-1.dll',
      'libbz2-2.dll'     => 'libbz2-2.dll',
      'libz-1.dll'       => 'libz-1.dll',
    }.each do |target, to|
      copy "#{install_dir}/embedded/mingw/bin/#{to}", "#{install_dir}/bin/#{target}"
    end
  end

  bundle "install", env: env
  gem "build hem.gemspec", env: env
  gem "install hem*.gem" \
      " --no-ri --no-rdoc" \
      " --verbose", env: env
  appbundle "hem"

  # HACK to inject the hem paths in to the appbundled binstub
  block do
    bin_file = File.read("#{install_dir}/bin/hem")
    path = [
      '#{File.expand_path("~/.hem/gems/ruby/#{RbConfig::CONFIG[\'ruby_version\']}/bin")}',
      "#{install_dir}/bin",
      "#{install_dir}/embedded/bin",
      '#{ENV[\'PATH\']}'
    ].join(':')

    bundler_unhook = <<-eos.strip
if defined?(Bundler)
  Bundler.with_clean_env do
    exec [$PROGRAM_NAME,$PROGRAM_NAME], *ARGV
  end
end

ENV['HEM_OMNIBUS'] = '1'

ENV
eos
    bin_file.sub!(/^ENV/, bundler_unhook)

    bin_file.sub!(/^Kernel/, "ENV['PATH'] = \"#{path}\"\nKernel")
    File.write("#{install_dir}/bin/hem", bin_file)
  end
end
