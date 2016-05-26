name "hem"
maintainer "Andy Thompson"
homepage "https://github.com/inviqa/hem"

install_dir     "#{default_root}/#{name}"
build_version   "1.0.1"
build_iteration "0.6.beta6"

# workaround for https://github.com/chef/omnibus-software/pull/473
override :ncurses, version: '5.9'
  
override :nokogiri, version: "1.6.3.1"
override :ruby,           version: "2.2.5"
override :'ruby-windows', version: "2.2.1"
override :'ruby-windows-devkit', version: "4.7.2-20130224"
override :rubygems,       version: "2.4.8"

# creates required build directories
dependency 'preparation'

# omnibus dependencies/components
dependency "hem"

# we make this happen after the fact so the gem installs in hem don't get messed up
dependency "rubygems-customization"

dependency "executable-hooks-patched"

# version manifest file
dependency 'version-manifest'

exclude "**/.git"
exclude "**/bundler/git"
exclude "**/embedded/man"
exclude "**/hem/omnibus-installer"
exclude "**/hem/specs"

package :deb do
  license 'MIT'
end

package :rpm do
  license 'MIT'
end

package :pkg do
  identifier "com.inviqa.pkg.hem"
end

package :msi do
  upgrade_code "A58AC989-0E19-42BC-A13F-415F274ED972"
  parameters({
    'RubyVersion' => '2.0.0'
  })
end

compress :dmg
