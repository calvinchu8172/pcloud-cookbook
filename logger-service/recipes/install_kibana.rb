execute "download kibana" do
  cwd "/tmp"
  command "wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz"
  not_if "test -f /tmp/kibana-4.0.1-linux-x64.tar.gz"
end

execute "setup kibana" do
  cwd "/srv"
  command <<-EOH
    tar xvfz /tmp/kibana-4.0.1-linux-x64.tar.gz && \
    cd kibana-4.0.1-linux-x64 && \
    ./bin/kibana &
  EOH
end
