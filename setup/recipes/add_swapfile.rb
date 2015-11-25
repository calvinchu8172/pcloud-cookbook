execute "generate swapfile" do
  command <<-EOF
    fallocate -l 2G /var/swapfile && \
    chmod 0600 /var/swapfile && \
    mkswap /var/swapfile
  EOF
  not_if "test -f /var/swapfile"
end

execute "enable swapfile" do
  command "swapon /var/swapfile"
  not_if "swapon -s | grep '/var/swapfile'"
end
