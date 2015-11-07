module Killjoy
  class Experiments
    attr_reader :configuration, :messages_to_process, :writers, :lines, :enable_profiler

    def initialize(enable_profiler: false)
      @enable_profiler = enable_profiler
      AfterFork.new.call
      @messages_to_process = ENV.fetch("MESSAGES", 1_000).to_i
      @writers = Spank::IOC.resolve_all(:writer)
      @mongo_client = Spank::IOC.resolve(:mongo_client)
      @lines = parse_log_lines(messages_to_process)
    end

    def publish_messages(message_bus)
      publisher = Publisher.new(message_bus)
      lines.each do |line|
        publisher.publish(line)
      end
    end

    def blocking_writes
      profile('tmp/cassandra-cpu-blocking-writes.dump') do
        run do |shard|
          Cassandra::BlockingWritesConsumer.new(writers, shard)
        end
      end
    end

    def non_blocking_writes
      profile('tmp/cassandra-cpu-non-blocking-writes.dump') do
        run do |shard|
          Cassandra::NonBlockingWritesConsumer.new(writers, shard)
        end
      end
    end

    def mongo_writes
      profile('tmp/mongo-cpu-non-blocking-writes.dump') do
        run do |shard|
          Mongo::Consumer.new(@mongo_client, shard)
        end
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

    def run
      queue_shards = ENV.fetch("RMQ_SHARDS", 4).to_i
      message_bus = MessageBus.new
      publish_messages(message_bus)

      queue = Queue.new
      mutex = Mutex.new
      resource = ConditionVariable.new

      queue_shards.times do |shard|
        consumer = yield(shard)
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

    def parse_log_lines(messages_to_process)
      parser = LogParser.new
      log_file = File.join(Dir.pwd, ENV.fetch("LOG_FILE", "spec/fixtures/nginx.log"))
      File.readlines(log_file).take(messages_to_process).map do |x|
        parser.parse(x)
      end
    end
  end
end
