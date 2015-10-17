module Killjoy
  class DatabaseCleaner
    def initialize(session, configuration)
      @session = session
      @configuration = configuration
    end

    def clean
      CassandraDb
        .from('system.schema_columnfamilies', @session)
        .where(keyspace_name: @configuration.keyspace)
        .each do |row|
        @session.execute("TRUNCATE #{row['columnfamily_name']}")
      end
    end
  end
end
