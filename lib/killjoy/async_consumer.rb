module Killjoy
  class AyncConsumer
    include Sneakers::Worker
    from_queue "sharding: shard.killjoy - rabbit@localhost - #{ENV.fetch("RMQ_SHARD", "1")}"

    def work_with_params(raw_message, delivery_info, metadata)
      tag_closure = delivery_info.delivery_tag
      message = JSON.parse(raw_message, symbolize_names: true)

      batch = batch_for(message)
      future = session.execute_async(batch)

      future.on_success do |values|
        channel.acknowledge(tag_closure, false)
      end
      future.on_failure do |error|
        channel.reject(tag_closure, false)
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

    private

    def batch_for(json)
      session.batch do |batch|
        writers.each do |writer|
          writer.save(json) do |statement, parameters|
            batch.add(statement, parameters)
          end
        end
      end
    end
  end
end
