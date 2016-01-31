module Killjoy
  module Kafka
    class Message
      attr_reader :to_hash, :info, :channel

      def initialize(raw_message)
        @to_hash = JSON.parse(raw_message, symbolize_names: true)
      end

      def process(future)
        future.on_success do |rows|
          ack!
        end
        future.on_failure do |error|
          reject!
        end
      end

      def ack!
        puts "TODO:: ack!"
      end

      def reject!(requeue = false)
        puts "TODO:: reject!"
      end

      def to_s
        to_hash
      end
    end
  end
end
