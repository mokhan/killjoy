module Killjoy
  class AsyncConsumer
    include Sneakers::Worker
    from_queue "sharding: shard.killjoy - rabbit@localhost - #{ENV.fetch("RMQ_SHARD", "1")}"

    def work_with_params(raw_message, delivery_info, metadata)
      message = JSON.parse(raw_message, symbolize_names: true)
      writes = writers.map do |writer|
        writer.write(message)
      end
      process(::Cassandra::Future.all(writes), delivery_info.delivery_tag)
    end

    private

    def process(future, tag)
      future.on_success do |rows|
        channel.acknowledge(tag, false)
      end
      future.on_failure do |error|
        channel.reject(tag, false)
      end
    end

    def channel
      @channel ||= @queue.instance_variable_get("@channel")
    end

    def session
      @session ||= Spank::IOC.resolve(:session)
    end

    def writers
      @writers ||= Spank::IOC.resolve_all(:writer)
    end
  end
end
