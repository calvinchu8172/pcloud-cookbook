# Security upgrade for USN-2783-1
# ref: http://www.ubuntu.com/usn/usn-2783-1/
#

execute 'apt-get update' do
  action :run
end

package 'ntp' do
  action :upgrade
end
