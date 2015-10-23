module Killjoy
  class MessageBus
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def run(consumer)
      options = { manual_ack: true, block: false }
      create_queue(consumer).subscribe(options) do |info, metadata, raw_message|
        begin
          message = JSON.parse(raw_message, symbolize_names: true)
          if consumer.work(message)
            ack(info)
          else
            reject(info)
          end
        rescue
          reject(info)
        end
      end
    end

    private

    def connection
      @connection ||= Bunny.new(
        configuration[:amqp_uri],
        heartbeat: configuration[:heartbeat]
      ).tap do |connection|
        connection.start
      end
    end

    def channel
      @channel ||= connection.create_channel.tap do |channel|
        channel.prefetch(configuration[:prefetch])
      end
    end

    def exchange
      @exchange ||= channel.exchange(
        configuration[:exchange],
        durable: true,
        type: configuration[:exchange_type]
      )
    end

    def create_queue(consumer)
      queue = channel.queue(consumer.queue_name, exclusive: false, durable: true)
      consumer.bindings.each do |binding|
        queue.bind(exchange, routing_key: binding)
      end
      queue
    end

    def ack(info)
      channel.acknowledge(info.delivery_tag, false)
    end

    def reject(info, requeue = false)
      channel.reject(info.delivery_tag, requeue)
    end
  end
end
