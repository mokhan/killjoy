module Killjoy
  class Experiments
    attr_reader :configuration, :messages_to_process, :writers, :lines, :enable_profiler

    def initialize(enable_profiler: false)
      @enable_profiler = enable_profiler
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
        queue_shards: ENV.fetch("RMQ_SHARDS", 4).to_i,
      }
      parser = Killjoy::LogParser.new
      log_file = File.join(Dir.pwd, ENV.fetch("LOG_FILE", "spec/fixtures/nginx.log"))
      @lines = File.readlines(log_file).take(messages_to_process).map do |x|
        parser.parse(x)
      end
    end

    def publish_messages
      Killjoy::Publisher.using do |publisher|
        lines.each do |line|
          publisher.publish(line)
        end
      end
    end

    def blocking_writes
      profile('tmp/stackprof-cpu-blocking-writes.dump') do
        run(Killjoy::Consumer)
      end
    end

    def non_blocking_writes
      profile('tmp/stackprof-cpu-non-blocking-writes.dump') do
        run(Killjoy::AsyncConsumer)
      end
    end

    private

    def profile(filename)
      if enable_profiler && RUBY_PLATFORM != "java"
        StackProf.run(mode: :cpu, out: filename) do
          yield
        end
      else
        yield
      end
    end

    def run(consumer_class)
      publish_messages

      queue = Queue.new
      mutex = Mutex.new
      resource = ConditionVariable.new
      message_bus = Killjoy::MessageBus.new(configuration)

      configuration[:queue_shards].times do |shard|
        consumer = consumer_class.new(writers, shard)
        message_bus.subscribe(consumer) do |message|
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
