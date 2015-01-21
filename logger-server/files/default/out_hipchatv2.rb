module Fluent
  class Hipchatv2Output < BufferedOutput
    COLORS = %w(yellow red green purple gray random)
    FORMAT = %w(html text)
    Fluent::Plugin.register_output('hipchatv2', self)

    config_param :api_token, :string
    config_param :default_room, :string, :default => nil
    config_param :default_color, :string, :default => nil
    config_param :default_from, :string, :default => nil
    config_param :default_notify, :bool, :default => false
    config_param :default_format, :string, :default => nil
    config_param :default_mention, :string, :default => nil
    config_param :default_timeout, :time, :default => nil
    config_param :http_proxy_host, :string, :default => nil
    config_param :http_proxy_port, :integer, :default => nil
    config_param :http_proxy_user, :string, :default => nil
    config_param :http_proxy_pass, :string, :default => nil
    config_param :flush_interval, :time, :default => 1

    attr_reader :hipchat

    def initialize
      super
      require 'hipchat'
    end

    def configure(conf)
      super

      api_token = conf['api_token']
      log.debug 'api token: ' + api_token
      @hipchat = HipChat::Client.new(api_token, :api_version => 'v2')
      @default_room = conf['default_room']
      @default_from = conf['default_from'] || 'fluentd'
      @default_notify = conf['default_notify'] || false
      @default_mention = conf['default_mention']
      @default_color = conf['default_color'] || 'yellow'
      @default_format = conf['default_format'] || 'html'
      @default_timeout = conf['default_timeout']
    end

    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    def write(chunk)
      chunk.msgpack_each do |(tag,time,record)|
        begin
          send_message(tag, record)
          set_topic(record) if record['topic']
        rescue => e
          $log.error("HipChat Error:", :error_class => e.class, :error => e.message)
        end
      end
    end

    def send_message(tag, record)
      room = record['room'] || @default_room
      from = record['from'] || @default_from
      message = "#{tag} #{record.to_s}"
      message = "@#{@default_mention} #{message}" if @default_mention
      notify = @default_notify

      color = COLORS.include?(record['color']) ? record['color'] : @default_color
      message_format = FORMAT.include?(record['format']) ? record['format'] : @default_format

      log.debug 'send to hipchat room:' + room + ', from:' + from + ', message:' + message + ', format:' + message_format + ', notify:' + notify.to_s + ', color:' + color
      @hipchat[room].send(from, message, :message_format => message_format, :notify => notify == 'true', :color => color)
    end

    def set_topic(record)
      room = record['room'] || @default_room
      from = record['from'] || @default_from
      topic = record['topic']
      @hipchat[room].topic(topic, :from => from)
    end
  end
end
