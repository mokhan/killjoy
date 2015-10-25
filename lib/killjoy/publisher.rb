module Killjoy
  class Publisher
    attr_reader :exchange_name, :exchange_type, :parser

    def initialize(exchange_name = "killjoy", exchange_type = 'x-modulus-hash')
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

    def publish(message)
      message.publish_to(exchange)
    end

    def dispose
      connection.close
    end

    private

    def connection
      @connection ||= Bunny.new(configuration, logger: Killjoy.logger).tap do |connection|
        connection.start
      end
    end

    def configuration
      ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672")
    end

    def channel
      @channel ||= connection.create_channel
    end

    def exchange
      @exchange ||= channel.exchange(exchange_name, durable: true, type: exchange_type)
    end
  end
end
