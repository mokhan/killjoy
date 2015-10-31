require "killjoy/consumer"

module Killjoy
  module Cassandra
    class NonBlockingWritesConsumer < Killjoy::Consumer
      def work(message)
        writes = writers.map do |writer|
          writer.write(message.to_hash, async: true)
        end
        message.process(::Cassandra::Future.all(writes))
      end
    end
  end
end