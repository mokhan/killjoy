module Killjoy
  class Publisher
    attr_reader :message_bus

    def initialize(configuration)
      @message_bus = MessageBus.new(configuration)
    end

    def self.using(configuration)
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
