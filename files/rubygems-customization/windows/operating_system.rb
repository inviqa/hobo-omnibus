## Rubygems Customization ##
# Customize rubygems install behavior and locations to keep user gems isolated
# from the stuff we bundle with omnibus and any other ruby installations on the
# system.

module Gem

  ##
  # Override user_dir to live inside of ~/.hem

  class << self
    # Remove method before redefining so we avoid a ruby warning
    remove_method :user_dir

    def user_dir
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

  class PathSupport
    def initialize(env=ENV)
      @env = env

      # note 'env' vs 'ENV'...
      @home     = env["GEM_HOME"] || ENV["GEM_HOME"] || Gem.user_dir

      if File::ALT_SEPARATOR then
        @home   = @home.gsub(File::ALT_SEPARATOR, File::SEPARATOR)
      end

      self.path = env["GEM_PATH"] || ENV["GEM_PATH"]

      @spec_cache_dir =
        env["GEM_SPEC_CACHE"] || ENV["GEM_SPEC_CACHE"] ||
          Gem.default_spec_cache_dir

      @spec_cache_dir = @spec_cache_dir.dup.untaint
    end
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
