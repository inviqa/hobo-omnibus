package 'createrepo'

template "#{node['hem-build']['gpg_userdir']}/.rpmmacros" do
  source 'dotrpmmacros.erb'
end
