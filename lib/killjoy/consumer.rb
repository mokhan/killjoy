module Killjoy
  class Consumer
    include Sneakers::Worker
    from_queue "sharding: shard.killjoy - rabbit@localhost - #{ENV.fetch("RMQ_SHARD", "1")}"

    if ENV["ASYNC"] == "true"
      def work_with_params(message, delivery_info, metadata)
        log ["ASYNC session:", session.object_id].inspect

        tag_closure = delivery_info.delivery_tag
        batch = batch_for(JSON.parse(message, symbolize_names: true))
        future = session.execute_async(batch)

        future.on_success do |values|
          log ["SUCCESS", values]
          channel.acknowledge(tag_closure, false)
        end
        future.on_failure do |error|
          log ["FAIL", error]
          channel.reject(tag_closure, false)
        end
      end

      def channel
        @channel ||= @queue.instance_variable_get("@channel")
      end
    else
      def work(message)
        log ["session:", session.object_id].inspect
        batch = batch_for(JSON.parse(message, symbolize_names: true))
        session.execute(batch)
        ack!
      end
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

    def log(messages)
      worker_trace [Thread.current.object_id, messages].flatten.inspect
    end
  end
end
