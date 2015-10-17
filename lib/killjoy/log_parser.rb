module Killjoy
  class LogParser
    def parse(line)
      regex = /^(\d{2,3}.\d{1,3}.\d{1,3}.\d{1,3}) - - \[(.*)\] "(\S*|\S* \/\S* \S*)" (\d{3}) (\d*) "(\S*)" "([^"]*)"$/
      matches = line.match(regex)
      return LogLine::NULL if matches.nil?

      LogLine.new(
        http_status: attempt(matches.captures, 3),
        http_verb: http_verb_from(matches.captures[2]),
        http_version: http_version_from(matches.captures[2]),
        ipaddress: matches.captures[0],
        timestamp: timestamp_from(matches.captures[1]),
        url: url_from(matches.captures[2]),
        user_agent: matches.captures[6],
      )
    end

    private

    def attempt(captures, index)
      captures[index]
    rescue StandardError => error
      puts error.message
    end

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
