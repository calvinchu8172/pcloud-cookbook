package "python-pip" do
  action :install
end

execute "pip install elasticsearch-curator" do
  command "pip install elasticsearch-curator"  
end
