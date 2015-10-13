require 'json'

module Killjoy
  class LogLine
    attr_accessor :timestamp, :ipaddress, :url, :http_verb, :http_version, :http_status, :user_agent

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

  class LogParser
    def parse(line)
      regex = /^(\d{2,3}.\d{1,3}.\d{1,3}.\d{1,3}) - - \[(.*)\] "(\S*|\S* \/\S* \S*)" (\d{3}) (\d*) "(\S*)" "([^"]*)"$/
      matches = line.match(regex)

      LogLine.new.tap do |model|
        model.timestamp = timestamp_from(matches.captures[1])
        model.ipaddress = matches.captures[0]
        model.url = url_from(matches.captures[2])
        model.http_verb = http_verb_from(matches.captures[2])
        model.http_version = http_version_from(matches.captures[2])
        model.http_status = matches.captures[3].to_i
        model.user_agent = matches.captures[6]
      end
    end

    private

    def timestamp_from(date)
      DateTime.strptime(date, "%d/%b/%Y:%H:%M:%S %z").to_time.to_i
    end

    def url_from(line)
      line.split(' ')[1]
    end

    def http_verb_from(line)
      line.split(' ')[0]
    end

    def http_version_from(line)
      line.split(' ')[2]
    end
  end
end
