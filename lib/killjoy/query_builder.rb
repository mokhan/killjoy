module Killjoy
  class QueryBuilder
    include Enumerable

    def initialize(table, session)
      @table = table
      @session = session
      @criteria = []
    end

    def map_using(mapper)
      @mapper = mapper
      self
    end

    def where(options)
      options.each do |(column, value)|
        @criteria << {
          cql: "#{@criteria.empty? ? "WHERE" : "AND" } #{column} = :#{column}",
          binding: [column.to_sym, type_for(value)]
        }
      end
      self
    end

    def contains(options)
      options.each do |(column, value)|
        @criteria << {
          cql: "AND #{column} CONTAINS :#{column}",
          binding: [column.to_sym, value]
        }
      end
      self
    end

    def limit(limit)
      cql("LIMIT #{limit.to_i}")
      self
    end

    def allow_filtering
      cql("ALLOW FILTERING")
      self
    end

    def cql(raw_cql)
      @criteria << { cql: raw_cql, binding: [:raw, nil] }
      self
    end

    def each(&block)
      @results ||= @mapper ? run.map { |x| @mapper.new(x) } : run
      @results.each(&block)
    end

    private

    def run
      cql = "SELECT * FROM #{@table} "
      arguments = {}
      type_hints = {}
      @criteria.each do |criteria|
        cql << "#{criteria[:cql]} "
        if criteria[:binding].compact.count == 2
          key, value = criteria[:binding][0], criteria[:binding][1]
          arguments[key] = value
          type_hints[key] = hint_for(value)
        end
      end
      @session.execute(cql, arguments: arguments, type_hints: type_hints)
    end

    def type_for(value)
      return Cassandra::Uuid.new(value) if guid?(value)
      value
    end

    def hint_for(value)
      return Cassandra::Types::Uuid if value.is_a?(Cassandra::Uuid)
      Cassandra::Util.guess_type(value)
    end

    def guid?(item)
      item =~ /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/
    end
  end
end
