module Killjoy
  module Kafka
    class Message
      attr_reader :to_hash

      def initialize(raw_message)
        @to_hash = JSON.parse(raw_message, symbolize_names: true)
        @interceptors = { ack: [], reject: [] }
      end

      def intercept(response_type, &block)
        @interceptors[response_type] << block
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
        #puts "TODO:: ack!"
        run_interceptors_for(:ack)
      end

      def reject!(requeue = false)
        #puts "TODO:: reject!"
        run_interceptors_for(:reject)
      end

      def to_s
        to_hash
      end

      private

      def run_interceptors_for(response_type)
        @interceptors[response_type].each do |interceptor|
          interceptor.call
        end
      end
    end
  end
end
