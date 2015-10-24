module Killjoy
  class Message
    attr_reader :to_hash, :info, :channel

    def initialize(raw_message, info, channel)
      @to_hash = JSON.parse(raw_message, symbolize_names: true)
      @info = info
      @channel = channel
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
      run_interceptors_for(:ack)
      channel.acknowledge(info.delivery_tag, false)
    end

    def reject!(requeue = false)
      run_interceptors_for(:reject)
      channel.reject(info.delivery_tag, requeue)
    end

    private

    def run_interceptors_for(response_type)
      @interceptors[response_type].each do |interceptor|
        interceptor.call
      end
    end
  end
end
