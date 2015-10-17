module Killjoy
  class CassandraDb
    def self.from(table, session)
      QueryBuilder.new(table, session)
    end
  end
end
