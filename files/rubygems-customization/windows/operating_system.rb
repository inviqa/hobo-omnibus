## Rubygems Customization ##
# Customize rubygems install behavior and locations to keep user gems isolated
# from the stuff we bundle with omnibus and any other ruby installations on the
# system.

# Always install and update new gems in "user install mode"
Gem::ConfigFile::OPERATING_SYSTEM_DEFAULTS["install"] = "--user"
Gem::ConfigFile::OPERATING_SYSTEM_DEFAULTS["update"] = "--user"

module Gem

  ##
  # Override user_dir to live inside of ~/.hem

  def self.user_dir
    hem_home_set = !([nil, ''].include? ENV['HEM_HOME'])
    # We call expand_path here because it converts \ -> /
    # Rubygems seems to require that we not use \
    default_home = File.join(File.expand_path(ENV['LOCALAPPDATA']), 'hem')

    hem_home = if hem_home_set
      ENV['HEM_HOME']
    else
      default_home
    end

    # Prevents multiple warnings
    ENV['HEM_HOME'] = hem_home

    parts = [hem_home, 'gems', ruby_engine]
    parts << RbConfig::CONFIG['ruby_version'] unless RbConfig::CONFIG['ruby_version'].empty?
    File.join parts
  end

end

# :DK-BEG: override 'gem install' to enable RubyInstaller DevKit usage
Gem.pre_install do |gem_installer|
  unless gem_installer.spec.extensions.empty?
    unless ENV['PATH'].include?('C:\\hem\\embedded\\mingw\\bin') then
      Gem.ui.say 'Temporarily enhancing PATH to include DevKit...' if Gem.configuration.verbose
      ENV['PATH'] = 'C:\\hem\\embedded\\bin;C:\\hem\\embedded\\mingw\\bin;' + ENV['PATH']
    end
    ENV['RI_DEVKIT'] = 'C:\\hem\\embedded'
    ENV['CC'] = 'gcc'
    ENV['CXX'] = 'g++'
    ENV['CPP'] = 'cpp'
  end
end
# :DK-END:
