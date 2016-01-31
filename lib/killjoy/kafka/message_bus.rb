module Killjoy
  module Kafka
    class MessageBus
      def initialize(topic = "killjoy_topic")
        @topic = topic
        @kafka_consumer = Poseidon::PartitionConsumer.new("killjoy_consumer", "localhost", 9092, @topic, 0, :earliest_offset)
        Thread.abort_on_exception = true
      end

      def subscribe(consumer)
        @thread = Thread.new do
          loop do
            messages = @kafka_consumer.fetch
            messages.each do |raw_message|
              begin
                #puts raw_message.value.inspect
                message = Message.new(raw_message.value)
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
        if @kafka_consumer
          @kafka_consumer.close
        else
          puts 'no consumer'
        end
        if @thread
          puts "KILL THE THREAD"
          Thread.kill(@thread)
          @thread = nil
        else
          puts 'no thread'
        end
      end

      def publish(message)
        message.publish_to(exchange)
      end

      private

      def exchange
        @exchange ||= KafkaExchange.new(@topic)
      end

      class KafkaExchange
        def initialize(topic)
          @topic = topic
          @producer = Poseidon::Producer.new(["localhost:9092"], "killjoy_producer")
        end

        def publish(json, options = {})
          #puts "publishing #{json.inspect}"
          @producer.send_messages([Poseidon::MessageToSend.new(@topic, json)])
        end
      end
    end
  end
end
