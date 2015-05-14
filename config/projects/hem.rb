name "hem"
maintainer "Mike Simons"
homepage "http://inviqa.com"

install_dir     "#{default_root}/#{name}"
build_version   "1.0.0-dev"
build_iteration 1

override :nokogiri, version: "1.6.3.1"
override :ruby,           version: "2.1.2"
override :'ruby-windows', version: "2.0.0-p451"
override :rubygems,       version: "2.4.1"

# creates required build directories
dependency 'preparation'

# omnibus dependencies/components
dependency "hem"

# we make this happen after the fact so the gem installs in hem don't get messed up
dependency "rubygems-customization"

# version manifest file
dependency 'version-manifest'

exclude "**/.git"
exclude "**/bundler/git"
exclude "**/embedded/man"
exclude "**/hem/omnibus-installer"
exclude "**/hem/specs"

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
