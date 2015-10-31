module Killjoy
  module Mongo
    class Consumer < Consumer
      attr_reader :mongo_client

      def initialize(mongo_client, shard)
        @mongo_client = mongo_client
        super(shard)
      end

      def work(message)
        mongo_client[:log_lines].insert_one(message.to_hash)
        message.ack!
      end
    end
  end
end
