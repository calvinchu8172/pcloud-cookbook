package "apt-transport-https" do
  action :install
end

execute "apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9" do
  user "root"
end

execute "add official docker repository" do
  user "root"
  command <<-EOH
    echo 'deb https://get.docker.com/ubuntu docker main' > /etc/apt/sources.list.d/docker.list && \
    apt-get update
  EOH
end

# install linux-image-extra package such as 'linux-image-extra-3.13.0-45-generic'
linux_image_extra_pkgname = "linux-image-extra-#{`uname -r`}".strip

package "#{linux_image_extra_pkgname}" do
  action :install
end

package "aufs-tools" do
  action :install
end

package "lxc-docker" do
  action :install
end
