
if platform_family?('rhel', 'fedora')
  include_recipe 'hem-build::_family_redhat'
end

if platform_family?('debian')
  include_recipe 'hem-build::_family_debian'
end
