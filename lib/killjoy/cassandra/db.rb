module Killjoy
  module Cassandra
    class Db
      def self.from(table, session = Spank::IOC.resolve(:session))
        QueryBuilder.new(table, session)
      end
    end
  end
end
