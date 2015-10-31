module Killjoy
  class AfterFork
    def call
      Killjoy::Startup.new(Spank::Container.new).run do |container|
        Spank::IOC.bind_to(container)
      end

      Signal.trap("TERM") do
        Spank::IOC.resolve(:session).close
        Spank::IOC.resolve(:cluster).close
      end
    rescue => error
      Killjoy.logger.error [error.message, error.backtrace].inspect
    end
  end
end
