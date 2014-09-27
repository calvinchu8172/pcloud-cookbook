execute "install mongooseim" do
  user "root"
  cwd "/tmp"
  command "wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb && sudo dpkg -i erlang-solutions_1.0_all.deb"
end
