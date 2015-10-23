module Killjoy
  class AsyncConsumer
    attr_reader :shard, :writers

    def initialize(writers, shard)
      @shard = shard
      @writers = writers
    end

    def work(message)
      writes = writers.map do |writer|
        writer.write(message.to_hash, async: true)
      end
      message.process(::Cassandra::Future.all(writes))
    end

    def bindings
      [queue_name]
    end

    def queue_name
      "sharding: killjoy - rabbit@localhost - #{shard}"
    end
  end
end
