module Killjoy
  class Worker
    include Sneakers::Worker
    from_queue "sharding: shard.killjoy - rabbit@localhost - #{ENV.fetch("RMQ_SHARD", "1")}"

    def work(message)
      puts ['thread', Thread.current.object_id].inspect
      batch = batch_for(JSON.parse(message, symbolize_names: true))
      session.execute(batch)
      ack!
    rescue => error
      puts ["ERROR", error.message, error.backtrace].inspect
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
            puts "writing batch"
            batch.add(statement, parameters)
          end
        end
      end
    end
  end
end
