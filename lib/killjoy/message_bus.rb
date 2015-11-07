module Killjoy
  class MessageBus
    attr_reader :configuration

    def initialize(configuration = AMQPConfiguration.new)
      @configuration = configuration
      @subscriptions = Queue.new
      @cpus = Facter.value('processors')['count'].to_i
    end

    def subscribe(consumer)
      options = { manual_ack: true, block: false }
      queue = create_queue(consumer)
      subscription = queue.subscribe(options) do |info, metadata, raw_message|
        begin
          message = Message.new(raw_message, info, channel)
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
      @subscriptions << subscription
    end

    def stop
      while @subscriptions.size > 0
        @subscriptions.deq.cancel
      end
      connection.close
    end

    def publish(message)
      message.publish_to(exchange)
    end

    private

    def connection
      @connection ||= Bunny.new(
        configuration.amqp_uri,
        heartbeat: configuration.heartbeat,
        logger: Killjoy.logger
      ).tap do |connection|
        connection.start
      end
    end

    def channel
      @channel ||= connection.create_channel(nil, @cpus).tap do |x|
        x.prefetch(configuration.prefetch)
      end
    end

    def exchange
      channel.exchange(
        configuration.exchange,
        durable: true,
        type: configuration.exchange_type
      )
    end

    def create_queue(consumer)
      queue = channel.queue(consumer.queue_name, exclusive: false, durable: true)
      consumer.bindings.each do |binding|
        queue.bind(exchange, routing_key: binding)
      end
      queue
    end
  end
end
