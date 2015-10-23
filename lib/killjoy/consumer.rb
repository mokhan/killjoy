module Killjoy
  class Consumer
    attr_reader :shard, :writers

    def initialize(writers, shard)
      @shard = shard
      @writers = writers
    end

    def work(message)
      writers.each do |writer|
        writer.write(message.to_hash)
      end
      message.ack!
    end

    def bindings
      [queue_name]
    end

    def queue_name
      "sharding: killjoy - rabbit@localhost - #{shard}"
    end
  end
end
