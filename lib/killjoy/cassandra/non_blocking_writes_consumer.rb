require "killjoy/consumer"

module Killjoy
  module Cassandra
    class NonBlockingWritesConsumer < Killjoy::Consumer
      attr_reader :writers

      def initialize(writers, shard)
        @writers = writers
        super(shard)
      end

      def work(message)
        writes = writers.map do |writer|
          writer.write(message.to_hash, async: true)
        end
        message.process(::Cassandra::Future.all(writes))
      end
    end
  end
end
