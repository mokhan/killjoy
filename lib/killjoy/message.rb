module Killjoy
  class Message
    attr_reader :to_hash, :info, :channel

    def initialize(raw_message, info, channel)
      @to_hash = JSON.parse(raw_message, symbolize_names: true)
      @info = info
      @channel = channel
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
      channel.acknowledge(info.delivery_tag, false)
    end

    def reject!(requeue = false)
      channel.reject(info.delivery_tag, requeue)
    end
  end
end
