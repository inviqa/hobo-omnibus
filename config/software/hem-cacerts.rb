#
# Copyright 2012-2014 Chef Software, Inc.
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

name "hem-cacerts"
default_version "0.0.1"

dependency "cacerts"

if windows?
  dependency "ruby-windows"
else
  dependency "ruby"
  dependency "rubygems"
end

build do
  block do
    # Copied from openssl-customization. Can we de-dupe?
    # gets directories for RbConfig::CONFIG and sanitizes them.
    def get_sanitized_rbconfig(config)
      ruby = windows_safe_path("#{install_dir}/embedded/bin/ruby")

      config_dir = Bundler.with_clean_env do
        command_output = %x|#{ruby} -rrbconfig -e "puts RbConfig::CONFIG['#{config}']"|.strip
        windows_safe_path(command_output)
      end

      if config_dir.nil? || config_dir.empty?
        raise "could not determine embedded ruby's RbConfig::CONFIG['#{config}']"
      end

      config_dir
    end

    embedded_ruby_site_dir = get_sanitized_rbconfig('sitelibdir')

    File.open("#{install_dir}/embedded/ssl/certs/cacert.pem", "a+") do |curl_cacert|
      Dir.glob("#{embedded_ruby_site_dir}/rubygems/ssl_certs/*.pem").each do |file|
        pem = File.read(file)
        curl_cacert.write "\n#{file}\n#{"=" * file.length}\n#{pem}"
      end
    end

    FileUtils.chmod(0644, "#{install_dir}/embedded/ssl/certs/cacert.pem")
  end
end
