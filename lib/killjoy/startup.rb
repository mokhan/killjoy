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
        Killjoy::DatabaseConfiguration.new
      end.as_singleton

      container.register(:cluster) do |x|
        configuration = x.resolve(:cassandra_configuration)
        ::Cassandra.cluster(
          compression: :lz4,
          consistency: :local_quorum,
          hosts: configuration.hosts,
          logger: Logger.new($stdout),
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

      [
        Killjoy::LogLineWriter
      ].each do |writer|
        container.register(:writer) do |x|
          writer.new(x.resolve(:session))
        end
      end
    end
  end
end
