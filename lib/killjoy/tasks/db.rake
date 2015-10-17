namespace :db do
  require 'active_support/core_ext/string'
  require 'erb'
  require 'fileutils'
  require 'yaml'
  require_relative '../database_configuration'

  def configuration
    @configuration ||= Killjoy::DatabaseConfiguration.new
  end

  task :expand_templates do
    Dir["db/migrate/*.cql.erb"].each do |file|
      configuration.expand(File.expand_path(file))
    end
  end

  desc "Create cassandra keyspace"
  task :create do
    host = configuration.hosts.first
    cql = <<-CQL
CREATE KEYSPACE #{configuration.keyspace} WITH REPLICATION = {
  'class' : 'SimpleStrategy',
  'replication_factor': 1
};
    CQL
    sh "cqlsh #{host} -e \"#{cql.gsub(/\n/, '')}\""
  end

  desc 'Run cassandra migrations'
  task :migrate => :expand_templates do
    host = configuration.hosts.first
    Dir["db/migrate/*.cql"].each do |file|
      sh "cqlsh #{host} -f #{File.expand_path(file)}"
    end
  end

  desc "Drop cassandra keyspace"
  task :drop do
    begin
      host = configuration.hosts.first
      cql = "DROP KEYSPACE #{configuration.keyspace};"
      sh "cqlsh #{host} -e '#{cql}'"
    rescue => error
      puts error.message
    end
  end

  desc "Reset cassandra keyspace"
  task :reset => [:drop, :create, :migrate]

  desc 'generate migration'
  task :generate_migration, [:name] do |task, arguments|
    name = arguments[:name]
    migration_time = DateTime.now.strftime("%Y%m%d%H%M%S")
    migration_name = "#{migration_time}_#{name.parameterize}.cql.erb"
    FileUtils.touch("db/migrate/#{migration_name}")
  end
end
