name "hobo-inviqa"
default_version "0.0.16-dev"

source :git => "git@github.com:inviqa/hobo-gem"

if windows?
  dependency "ruby-windows"
else
  dependency "ruby"
  dependency "rubygems"
end

dependency "cacerts"
dependency "openssl-customization"

# The devkit has to be installed after openssl-customization so the
# file it installs gets patched.
dependency "ruby-windows-devkit" if windows?

# Pre-compile lib dependencies
dependency "dep-selector-libgecode"
dependency "nokogiri"
dependency "bundler"
dependency "appbundler"
dependency "hobo-cacerts"

build do
  env = with_standard_compiler_flags(with_embedded_path)

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
  appbundle "hobo-inviqa"

  # HACK to inject the hobo paths in to the appbundled binstub
  block do
    bin_file = File.read("#{install_dir}/bin/hobo")
    File.write("#{install_dir}/bin/hobo", bin_file.gsub(/^Kernel/, "ENV['PATH'] = \"#{install_dir}/bin:#{install_dir}/embedded/bin:\#{ENV['PATH']}\"\nKernel"))
  end
end
