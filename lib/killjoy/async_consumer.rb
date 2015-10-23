module Killjoy
  class AsyncConsumer
    attr_reader :shard, :writers

    def initialize(writers, shard)
      @shard = shard
      @writers = writers
    end

    def work(message, delivery_info)
      writes = writers.map do |writer|
        writer.write(message)
      end
      process(::Cassandra::Future.all(writes), delivery_info.delivery_tag)
    end

    def bindings
      [queue_name]
    end

    def queue_name
      "sharding: killjoy - rabbit@localhost - #{shard}"
    end

    private

    def process(future, tag)
      future.on_success do |rows|
        worker_trace("ACK: #{tag}")
        channel.acknowledge(tag, false)
      end
      future.on_failure do |error|
        worker_trace("NACK: #{tag}")
        channel.reject(tag, false)
      end
    end

    def channel
      @channel ||= @queue.instance_variable_get("@channel")
    end
  end
end
