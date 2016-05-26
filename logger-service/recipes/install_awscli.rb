package 'python' do
  action :install
end

package 'python-dev' do
  action :install
end

execute 'install pip' do
  command 'curl -O https://bootstrap.pypa.io/get-pip.py && python get-pip.py'
  creates '/usr/local/bin/pip'
end

execute 'install & upgrade awscli' do
  command 'pip install --upgrade awscli'
end
