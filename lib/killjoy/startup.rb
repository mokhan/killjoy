module Killjoy
  class Startup
    def initialize(container)
      @container = container
    end

    def run
      configure(@container)
      yield @container
    end

    private

    def configure(container)
      container.register(:cassandra_configuration) do |x|
        Killjoy::Cassandra::DatabaseConfiguration.new
      end.as_singleton

      container.register(:cluster) do |x|
        configuration = x.resolve(:cassandra_configuration)
        ::Cassandra.cluster(
          compression: :lz4,
          consistency: :local_quorum,
          hosts: configuration.hosts,
          logger: Killjoy.logger,
          nodelay: true,
          port: configuration.port,
          timeout: nil,
          idle_timeout: nil,
          trace: true,
        )
      end.as_singleton

      container.register(:session) do |x|
        keyspace = x.resolve(:cassandra_configuration).keyspace
        x.resolve(:cluster).connect(keyspace)
      end.as_singleton

      container.register(:mongo_client) do |x|
        connection_string = ENV.fetch("MONGO_CONNECTION_STRING", 'mongodb://127.0.0.1:27017/killjoy')
        ::Mongo::Logger.logger = Killjoy.logger
        ::Mongo::Client.new(connection_string)
      end.as_singleton

      container.register(:writer) do |x|
        session = x.resolve(:session)
        writers = x.resolve_all(:cassandra_writer)
        Killjoy::Cassandra::Writer.new(session, writers)
      end

      [
        Killjoy::Cassandra::LogLineWriter
      ].each do |writer|
        container.register(:cassandra_writer) do |x|
          writer.new(x.resolve(:session))
        end
      end
    end
  end
end
