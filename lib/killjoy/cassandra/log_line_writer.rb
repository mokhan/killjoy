module Killjoy
  module Cassandra
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
        @generator = ::Cassandra::Uuid::Generator.new
      end

      def save(json)
        yield statement, parameters_for(json)
      end

      private

      def parameters_for(json)
        time = Time.at(json[:timestamp].to_i)
        json.merge(
          id: @generator.at(time),
          ipaddress: IPAddr.new(json[:ipaddress]),
          timestamp: time
        )
      end
    end
  end
end
