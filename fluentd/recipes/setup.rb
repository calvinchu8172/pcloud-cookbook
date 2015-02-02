# create user 'fluentd'

user "fluentd" do
  supports :manage_home => true
  comment "Fluentd specific account"
  home "/home/fluentd"
  shell "/bin/bash"
  action :create
end
