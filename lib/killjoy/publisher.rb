module Killjoy
  class Publisher
    attr_reader :message_bus

    def initialize(configuration)
      @message_bus = MessageBus.new(configuration)
    end

    def self.using
      configuration = {
        amqp_uri: ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"),
        exchange: 'killjoy',
        exchange_type: 'x-modulus-hash',
        heartbeat: 2,
        prefetch: 8,
      }
      publisher = new(configuration)
      yield publisher
    ensure
      publisher.dispose
    end

    def publish(message)
      message_bus.publish(message)
    end

    def dispose
      message_bus.stop
    end
  end
end
