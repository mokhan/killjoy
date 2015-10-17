module Killjoy
  class Publisher
    attr_reader :exchange_name, :exchange_type, :parser

    def initialize(exchange_name = "shard.killjoy", exchange_type = 'x-modulus-hash')
      @exchange_name = exchange_name
      @exchange_type = exchange_type
      @parser = LogParser.new
    end

    def self.use
      publisher = new
      yield publisher
    ensure
      publisher.dispose
    end

    def publish(line)
      parser.parse(line).publish_to(exchange)
    rescue => error
      puts [error.message, error.backtrace.first, line].inspect
    end

    def dispose
      connection.close
    end

    private

    def connection
      @connection ||= Bunny.new(configuration).tap do |connection|
        connection.start
      end
    end

    def configuration
      {
        host: ENV.fetch("RMQ_HOST", "localhost"),
        password: ENV.fetch("RMQ_PASSWORD", "guest"),
        port: ENV.fetch("RMQ_PORT", 5672).to_i,
        username: ENV.fetch("RMQ_USERNAME", "guest"),
      }
    end

    def channel
      @channel ||= connection.create_channel
    end

    def exchange
      @exchange ||= channel.exchange(exchange_name, durable: true, type: exchange_type)
    end

    #"http_status.ip.unix_timestamp"
    def routing_key_for(line)
      "#{line.http_status}.#{line.ipaddress}.#{line.timestamp}"
    end
  end
end
