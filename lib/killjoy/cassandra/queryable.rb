require 'active_support/concern'

module Killjoy
  module Cassandra
    module Queryable
      extend ActiveSupport::Concern
      class_methods do
        def all
          Cassandra::Db.from(table_name).map_using(self)
        end

        def table_name
          @table_name ||= self.name.tableize.split('/').last.to_sym
        end
      end
    end
  end
end
