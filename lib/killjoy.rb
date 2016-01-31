require "active_support/core_ext/string"
require "bunny"
require "cassandra"
require "erb"
require "facter"
require "json"
require "killjoy/nullable"
require "logger"
require "mongo"
require "poseidon"
require "spank"
require "virtus"
require "yaml"

require "killjoy/after_fork"
require "killjoy/cassandra/blocking_writes_consumer"
require "killjoy/cassandra/database_cleaner"
require "killjoy/cassandra/database_configuration"
require "killjoy/cassandra/db"
require "killjoy/cassandra/log_line_writer"
require "killjoy/cassandra/non_blocking_writes_consumer"
require "killjoy/cassandra/query_builder"
require "killjoy/cassandra/queryable"
require "killjoy/cassandra/writer"
require "killjoy/consumer"
require "killjoy/kafka/message"
require "killjoy/kafka/message_bus"
require "killjoy/log_line"
require "killjoy/log_parser"
require "killjoy/mongo/consumer"
require "killjoy/publisher"
require "killjoy/rmq/amqp_configuration"
require "killjoy/rmq/message"
require "killjoy/rmq/message_bus"
require "killjoy/thread_pool"
require "killjoy/version"

require "killjoy/startup"

module Killjoy
  def self.logger
    if @logger.nil?
      logger = Logger.new(STDOUT)
      logger.level = Logger::WARN
      Killjoy.logger = logger
    end
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end
