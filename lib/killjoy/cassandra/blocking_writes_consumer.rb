require "killjoy/consumer"

module Killjoy
  module Cassandra
    class BlockingWritesConsumer < Killjoy::Consumer
      attr_reader :writers

      def initialize(writers, shard)
        @writers = writers
        super(shard)
      end

      def work(message)
        writers.each do |writer|
          writer.write(message.to_hash)
        end
        message.ack!
      end
    end
  end
end
