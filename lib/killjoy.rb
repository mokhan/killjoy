require "active_support/core_ext/string"
require "bunny"
require "cassandra"
require "facter"
require "json"
require "killjoy/nullable"
require "killjoy/queryable"
require "logger"
require "spank"
require "virtus"

require "killjoy/after_fork"
require "killjoy/async_consumer"
require "killjoy/cassandra_db"
require "killjoy/cassandra_writer"
require "killjoy/consumer"
require "killjoy/database_cleaner"
require "killjoy/database_configuration"
require "killjoy/log_line"
require "killjoy/log_line_writer"
require "killjoy/log_parser"
require "killjoy/message"
require "killjoy/message_bus"
require "killjoy/publisher"
require "killjoy/query_builder"
require "killjoy/version"

require "killjoy/startup"

module Killjoy
  def self.logger
    if @logger.nil?
      Killjoy.logger = Logger.new(STDOUT)
      Killjoy.logger.level = Logger::WARN
    end
    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end
end
