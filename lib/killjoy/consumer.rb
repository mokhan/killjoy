module Killjoy
  class Consumer
    include Sneakers::Worker
    from_queue "sharding: shard.killjoy - rabbit@localhost - #{ENV.fetch("RMQ_SHARD", "1")}"

    def work(raw_message)
      worker_trace("processing #{raw_message}")
      message = JSON.parse(raw_message, symbolize_names: true)
      writers.each do |writer|
        writer.write(message)
      end
      ack!
    end

    def writers
      @writers ||= Spank::IOC.resolve_all(:writer)
    end
  end
end
