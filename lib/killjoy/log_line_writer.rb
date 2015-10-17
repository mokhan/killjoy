module Killjoy
  class LogLineWriter
    CQL = <<-CQL
INSERT INTO log_lines(
  id,
  http_status,
  http_verb,
  http_version,
  ipaddress,
  timestamp,
  url,
  user_agent
)
VALUES (
  :id,
  :http_status,
  :http_verb,
  :http_version,
  :ipaddress,
  :timestamp,
  :url,
  :user_agent
)
    CQL

    attr_reader :statement

    def initialize(session)
      @session = session
      @statement = @session.prepare(CQL)
      @generator = Cassandra::Uuid::Generator.new
    end

    def save(json)
      puts ["SAVING", json].inspect
      yield statement, parameters_for(json)
    end

    private

    def parameters_for(json)
      json.merge(
        id: @generator.now,
        ipaddress: IPAddr.new(json[:ipaddress]),
        timestamp: Time.at(json[:timestamp].to_i),
      )
    end
  end
end
