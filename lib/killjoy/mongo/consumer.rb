module Killjoy
  module Mongo
    class Consumer < Consumer
      def initialize(writers, shard)
        @mongo_client = Spank::IOC.resolve(:mongo_client)
        super(writers, shard)
      end

      def work(message)
        Killjoy.logger.info "[#{Thread.current.object_id}] got message: #{message}"
        mongo_client[:log_lines].insert_one(message.to_hash)
        message.ack!
      end
    end
  end
end
