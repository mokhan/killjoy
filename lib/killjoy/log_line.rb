module Killjoy
  class LogLine
    include Virtus.model
    include Queryable

    NULL = Nullable.new

    attribute :http_status, Integer
    attribute :http_verb, String
    attribute :http_version, String
    attribute :ipaddress, String
    attribute :timestamp, Integer
    attribute :url, String
    attribute :user_agent, String

    def to_json
      JSON.generate(attributes)
    end

    def publish_to(exchange)
      exchange.publish(to_json, routing_key: routing_key)
    end

    class << self
      def from_ip(ipaddress)
        all.where(ipaddress: ipaddress)
      end
    end

    private

    def routing_key
      "#{http_status}.#{ipaddress}.#{timestamp}"
    end
  end
end
