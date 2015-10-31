module Killjoy
  module Cassandra
    class Writer
      attr_reader :session, :writers

      def initialize(session, cassandra_writers)
        @session = session
        @writers = cassandra_writers
      end

      def write(message, async: false)
        if async
          session.execute_async(batch_for(message))
        else
          session.execute(batch_for(message))
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
end
