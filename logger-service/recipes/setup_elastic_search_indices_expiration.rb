package "python-pip" do
  action :install
end

execute "pip install elasticsearch-curator" do
  command "pip install elasticsearch-curator"  
end

cron "elasticsearch_indices_expiration" do
  minute '00'
  hour '11'
  command "/usr/local/bin/curator delete indices --older-than 90 --time-unit days --timestring '%Y.%m.%d' > /dev/null 2>&1"
end
