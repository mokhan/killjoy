shared_context "with_cassandra" do
  let(:configuration) { Killjoy::Cassandra::DatabaseConfiguration.new(environment: "test") }
  let(:cluster) do
    ::Cassandra.cluster(
      #compression: :lz4,
      consistency: :local_quorum,
      hosts: configuration.hosts,
      #logger: Logger.new($stdout),
      #nodelay: true,
      port: configuration.port,
      #timeout: nil,
      #idle_timeout: nil,
      trace: true,
    )
  end
  let(:session) { cluster.connect(configuration.keyspace) }

  before :each do
    Killjoy::Cassandra::DatabaseCleaner.new(session, configuration).clean
  end
end
