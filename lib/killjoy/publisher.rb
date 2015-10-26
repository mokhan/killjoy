module Killjoy
  class Publisher
    attr_reader :message_bus

    def initialize(message_bus)
      @message_bus = message_bus
    end

    def self.using(message_bus)
      publisher = new(message_bus)
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
