execute "install mongooseim" do
  user "root"
  cwd "/tmp"
  command <<-EOH
    wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && \
    dpkg -i erlang-solutions_1.0_all.deb && \
    apt-get update && \
    apt-get -y install mongooseim && \
    apt-get -y install mysql-client-5.6 && \
    apt-get -y install redis-tools
  EOH
end
