# Security upgrade for USN-2869-1
# ref: http://www.ubuntu.com/usn/usn-2869-1/
#

execute 'apt-get update' do
  action :run
end

package 'openssh-client' do
  action :upgrade
end
