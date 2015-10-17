module Killjoy
  class LogLine
    attr_accessor :timestamp, :ipaddress, :url, :http_verb, :http_version, :http_status, :user_agent

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        self.send("#{attribute}=", value)
      end
    end

    def to_json
      JSON.generate({
        timestamp: timestamp,
        ipaddress: ipaddress,
        url: url,
        http_verb: http_verb,
        http_version: http_version,
        http_status: http_status,
        user_agent: user_agent,
      })
    end
  end
end
