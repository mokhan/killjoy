module Killjoy
  class Worker
    include Sneakers::Worker
    from_queue "sharding: shard.killjoy - rabbit@localhost - #{ENV.fetch("RMQ_SHARD", "1")}"

    def work(message)
      puts Thread.current.object_id
      #batch = batch_for(JSON.parse(message, symbolize_names: true))
      #session.execute(batch)
      ack!
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
