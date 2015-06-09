require 'open-uri'

include_recipe "common::install_official_docker" 

ruby_block "detect if eth1 is exists" do
  block do
    eth1 = `ifconfig -a |grep eth1`

    if eth1.empty?
      Chef::Log.info("--= Please setup a secondary networking interface & assign an Elastic IP to it. =--")
      raise "Invalid secondary networking interface"
    end
  end
end

execute "enable eth1" do
  command "ifconfig eth1 up"
end

execute "Setup eth1 via DHCP" do
  command "dhclient eth1"
end

# Now we have to deal with multiple routes

eth0_mac = /link\/ether\s(.*)\sbrd/.match(`ip -o -0 addr list eth0`)[1]
eth1_mac = /link\/ether\s(.*)\sbrd/.match(`ip -o -0 addr list eth1`)[1]

subnet = open("http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth0_mac}/subnet-ipv4-cidr-block").read
gateway = `route -n | grep "UG" | awk '{print ($2)}'`.chomp!

eth0_ipv4_private = open("http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth0_mac}/local-ipv4s").read
eth1_ipv4_private = open("http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth1_mac}/local-ipv4s").read

eth0_ipv4_public = open("http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth0_mac}/public-ipv4s").read
eth1_ipv4_public = open("http://169.254.169.254/latest/meta-data/network/interfaces/macs/#{eth1_mac}/public-ipv4s").read

execute "setup advance routes" do
  command <<-EOF
    ip route add #{subnet} dev eth0 proto kernel scope link src #{eth0_ipv4_private} table 20 && \
    ip route add default via #{gateway} dev eth0 table 20 && \
    ip rule add from #{eth0_ipv4_private} lookup 20 && \
    ip route add #{subnet} dev eth1 proto kernel scope link src #{eth1_ipv4_private} table 30 && \
    ip route add default via #{gateway} dev eth1 table 30 && \
    ip rule add from #{eth1_ipv4_private} lookup 30
  EOF

  only_if { `ip route list table 30`.empty? }
end

execute "mkdir for Docker files" do
  cwd "/srv"
  command "mkdir -p stunserver"
end

cookbook_file "Dockerfile" do
  source "Dockerfile"
  path "/srv/stunserver/Dockerfile"
  action :create
end

execute "build stunserver docker image" do
  cwd "/srv/stunserver"
  command "docker build -t stunserver ."
end

execute "kill existed stunserver" do
  command "docker rm -f stunserver-instance"
  only_if "docker ps -a | grep 'stunserver-instance'"
end

execute "run stunserver in docker" do
  command <<-EOF
  docker run -d --net=host --name=stunserver-instance stunserver \
    /opt/stunserver/stunserver --mode full \
      --primaryinterface eth0 --altinterface eth1 \
      --primaryadvertised #{eth0_ipv4_public} --altadvertised #{eth1_ipv4_public}
  EOF
end
