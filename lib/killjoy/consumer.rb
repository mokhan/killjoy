module Killjoy
  class Consumer
    attr_reader :shard, :writers

    def initialize(writers, shard)
      @shard = shard
      @writers = writers
    end

    def work(message)
      raise "NotImplementedException"
    end

    def bindings
      [queue_name]
    end

    def queue_name
      "sharding: killjoy - rabbit@localhost - #{shard}"
    end
  end
end
