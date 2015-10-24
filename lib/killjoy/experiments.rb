module Killjoy
  class Experiments
    attr_reader :configuration, :messages_to_process, :writers, :lines

    def initialize
      Killjoy::AfterFork.new.call
      @messages_to_process = ENV.fetch("MESSAGES", 1_000).to_i
      @writers = Spank::IOC.resolve_all(:writer)
      cpus = Facter.value('processors')['count'].to_i
      @configuration = {
        amqp_uri: ENV.fetch("RABBITMQ_URL", "amqp://guest:guest@localhost:5672"),
        exchange: 'killjoy',
        exchange_type: 'x-modulus-hash',
        heartbeat: 2,
        prefetch: cpus,
      }
      parser = Killjoy::LogParser.new
      log_file = File.join(Dir.pwd, ENV.fetch("LOG_FILE", "spec/fixtures/nginx.log"))
      @lines = File.readlines(log_file).take(messages_to_process).map do |x|
        parser.parse(x)
      end
    end

    def publish_messages
      Killjoy::Publisher.use do |publisher|
        lines.each do |line|
          publisher.publish(line)
        end
      end
    end

    def blocking_writes
      run(Killjoy::Consumer)
    end

    def non_blocking_writes
      run(Killjoy::AsyncConsumer)
    end

    private

    def run(consumer_class)
      publish_messages

      queue = Queue.new
      mutex = Mutex.new
      resource = ConditionVariable.new
      message_bus = Killjoy::MessageBus.new(configuration)

      4.times do |shard|
        consumer = consumer_class.new(writers, shard)
        message_bus.run(consumer) do |message|
          message.intercept(:ack) do
            queue << message
            if queue.size == messages_to_process
              mutex.synchronize do
                resource.signal
              end
            end
          end
          consumer.work(message)
        end
      end

      mutex.synchronize do
        resource.wait(mutex)
        message_bus.stop
      end
    end
  end
end
