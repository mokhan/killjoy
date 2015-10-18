module Killjoy
  class CassandraDb
    def self.from(table, session = Spank::IOC.resolve(:session))
      QueryBuilder.new(table, session)
    end
  end
end
