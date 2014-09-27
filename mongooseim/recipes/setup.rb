execute "setup mongooseim repository" do
  user "root"
  cwd "/tmp"
  command <<-EOH
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update
  EOH
  not_if "dpkg-query -W mongooseim"
end

package "mongooseim" do
  action :install
end

package "mysql-client" do
  action :install
end

package "redis-tools" do
  action :install
end
