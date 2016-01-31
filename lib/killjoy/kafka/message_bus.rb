module Killjoy
  module Kafka
    class MessageBus
      def subscribe(consumer)
        @thread = Thread.new do
          consumer = Poseidon::PartitionConsumer.new("killjoy_consumer", "localhost", 9092, "killjoy_topic", 0, :earliest_offset)

          loop do
            messages = consumer.fetch
            messages.each do |raw_message|
              begin
                message = KafkaMessage.new(raw_message)
                if block_given?
                  yield message
                else
                  consumer.work(message)
                end
              rescue => error
                Killjoy.logger.error(error.message)
                message.reject!
              end
            end
          end
        end
      end

      def stop
        @thread.terminate if @thread
      end

      def publish(message)
        message.publish_to(exchange)
      end

      private

      def exchange
        @exchange ||= KafkaExchange.new
      end

      class KafkaExchange
        def initialize
          @producer = Poseidon::Producer.new(["localhost:9092"], "killjoy_producer")
        end

        def publish(json, options = {})
          puts "publishing #{json.inspect}"
          @producer.send_messages([Poseidon::MessageToSend.new("killjoy_topic", json)])
        end
      end
    end
  end
end
