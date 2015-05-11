cron "fluentd_log_expiration" do
  minute '00'
  hour '11'
  command "find /var/log/fluent/ -ctime +30 -delete"
end
