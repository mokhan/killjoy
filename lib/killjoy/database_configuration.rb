require 'erb'
require 'yaml'

module Killjoy
  class DatabaseConfiguration
    attr_reader :environment

    def initialize(environment = ENV.fetch("ENV", "development"))
      @environment = environment
    end

    def hosts
      configuration["hosts"]
    end

    def keyspace
      configuration["keyspace"]
    end

    def port
      configuration["port"].to_i
    end

    def expand(file)
      new_path = file.gsub(/\.erb/, '')
      IO.write(new_path, expand_template(file))
    end

    private

    def configuration(file = "config/database.yml")
      @configuration ||= 
        YAML.load(expand_template(file))[environment]
    end

    def expand_template(file)
      ERB.new(File.read(file)).result(binding)
    end
  end
end
