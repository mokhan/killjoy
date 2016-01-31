module Killjoy
  module Worker
    def initialize
      @mutex = ServerEngine::BlockingFlag.new
      #@message_bus = Killjoy::MessageBus.new
      @message_bus = Killjoy::Kafka::MessageBus.new
    end

    def run
      after_fork

      writers = Spank::IOC.resolve_all(:writer)

      config[:queue_shards].times do |shard|
        consumer = Cassandra::NonBlockingWritesConsumer.new(writers, shard)
        @message_bus.subscribe(consumer)
      end
      @mutex.wait
    end

    def stop
      @message_bus.stop
      @mutex.set!
    end

    private

    def after_fork
      Killjoy::AfterFork.new.call
    end
  end
end
