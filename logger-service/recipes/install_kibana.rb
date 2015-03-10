kibana = "kibana-4.0.1-linux-x64"

execute "download kibana" do
  cwd "/tmp"
  command "wget https://download.elasticsearch.org/kibana/kibana/#{kibana}.tar.gz"
  not_if "test -f /tmp/#{kibana}.tar.gz"
end

execute "setup kibana" do
  cwd "/srv"
  command "tar xvfz /tmp/#{kibana}.tar.gz"
end

bash "run kibana" do
  code "/srv/#{kibana}/bin/kibana -q &"
end
