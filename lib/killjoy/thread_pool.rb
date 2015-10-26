module Killjoy
  class ThreadPool
    include Enumerable

    def initialize(max = Facter.value('processors')['count'].to_i)
      @threads = []
      @jobs = Queue.new
      Thread.abort_on_exception = true

      max.times do |n|
        @threads << Thread.new do
          loop do
            job = @jobs.deq
            Killjoy.logger.debug("[#{Thread.current.object_id}] invoking job")
            job.call
            Killjoy.logger.debug("[#{Thread.current.object_id}] finish job")
          end
        end
      end
    end

    def run(&block)
      @jobs << block
      Killjoy.logger.debug("[#{Thread.current.object_id}] queue up a job. count: #{@jobs.size}")
    end

    def stop
      @jobs.clear
      if block_given?
        each do |thread|
          yield thread
          Thread.kill(thread)
        end
      end
    end

    def each(&block)
      @threads.each(&block)
    end
  end
end
