module Killjoy
  class LogLine
    include Virtus.model
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
  end
end
