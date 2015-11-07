module Killjoy
  class AMQPConfiguration
    attr_reader :environment

    def initialize(environment: ENV.fetch("ENV", "development"))
      @environment = environment
    end

    def amqp_uri
      configuration['amqp_uri']
    end

    def heartbeat
      configuration['heartbeat'].to_i
    end

    def prefetch
      configuration['prefetch'].to_i
    end

    def exchange
      configuration['exchange']
    end

    def exchange_type
      configuration['exchange_type']
    end

    def shards
      configuration['shards'].to_i
    end

    def to_hash
      configuration
    end

    private

    def configuration(file = "config/amqp.yml")
      @configuration ||= YAML.load(expand_template(file))[environment]
    end

    def expand_template(file)
      ERB.new(File.read(file)).result(binding)
    end
  end
end
