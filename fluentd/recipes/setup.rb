# create user 'fluentd'

user "fluentd" do
  supports :manage_home => true
  comment "Fluentd specific account"
  home "/home/fluentd"
  shell "/bin/bash"
  action :create
end

# install RVM for user 'fluentd'

execute "install RVM" do
  user "fluentd"
  environment ({'HOME' => '/home/fluentd'})
  command <<-EOH
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3 && \
    curl -sSL https://get.rvm.io | bash -s stable --ruby
  EOH
end
