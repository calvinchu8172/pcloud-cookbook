set[:nginx][:log_format] = {'proxied_combined' => '$http_x_forwarded_for - $remote_user [$time_local]  "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'}
