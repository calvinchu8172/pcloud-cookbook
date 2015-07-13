kibana = "kibana-4.1.0-linux-x64"

execute "download kibana" do
  cwd "/tmp"
  command "wget https://download.elasticsearch.org/kibana/kibana/#{kibana}.tar.gz"
  not_if "test -f /tmp/#{kibana}.tar.gz"
end

execute "setup kibana" do
  cwd "/srv"
  command <<-EOF
    tar xvfz /tmp/#{kibana}.tar.gz && \
    sed -i '/^#\spid_file/s/^#\s//' /srv/#{kibana}/config/kibana.yml
  EOF
end

execute "kill running kibana" do
  command "kill `/bin/cat /var/run/kibana.pid`"
  #only_if "ps -ef | grep 'node.*kibana\.js'"
  only_if "test -f /var/run/kibana.pid"
end

bash "run kibana" do
  code "/srv/#{kibana}/bin/kibana -q &"
end
