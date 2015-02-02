# create user 'fluentd'

user "fluentd" do
  comment "Fluentd specific account"
  supports :manage_home => true
  action :create
end
