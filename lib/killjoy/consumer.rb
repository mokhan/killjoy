module Killjoy
  class Consumer
    attr_reader :shard

    def initialize(shard)
      @shard = shard
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
