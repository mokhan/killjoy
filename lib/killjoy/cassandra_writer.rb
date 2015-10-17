module Killjoy
  class CassandraWriter
    attr_reader :session, :writers

    def initialize(session, cassandra_writers)
      @session = session
      @writers = cassandra_writers
    end

    def write(message)
      batch = batch_for(message)
      if ENV['ASYNC'] == 'true'
        session.execute_async(batch)
      else
        session.execute(batch)
      end
    end

    private

    def batch_for(json)
      session.batch do |batch|
        writers.each do |writer|
          writer.save(json) do |statement, parameters|
            batch.add(statement, parameters)
          end
        end
      end
    end
  end
end
