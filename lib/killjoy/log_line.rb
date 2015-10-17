module Killjoy
  class LogLine
    attr_accessor :timestamp, :ipaddress, :url, :http_verb, :http_version, :http_status, :user_agent

    def initialize(attributes = {})
      attributes.each do |attribute, value|
        self.send("#{attribute}=", value)
      end
      @attributes = attributes
    end

    def to_json
      JSON.generate(@attributes)
    end
  end
end
