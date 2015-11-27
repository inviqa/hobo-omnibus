include_recipe 'apt'
include_recipe 'aptly'

template "#{node['hem-build']['gpg_userdir']}/.aptly.conf" do
  source 'aptly.conf.erb'
end
