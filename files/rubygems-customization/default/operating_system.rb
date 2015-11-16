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
      parts = [Gem.user_home, '.hem', 'gems', ruby_engine]
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
