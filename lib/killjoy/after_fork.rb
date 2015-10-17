module Killjoy
  class AfterFork
    def call
      puts "AFTER FORK #{Process.pid}"
      Killjoy::Startup.new(Spank::Container.new).run do |container|
        Spank::IOC.bind_to(container)
        Spank::IOC.resolve(:session).execute("select * from system.hints;")
      end

      Signal.trap("TERM") do
        Spank::IOC.resolve(:session).close
        Spank::IOC.resolve(:cluster).close
      end
    rescue => error
      puts [error.message, error.backtrace].inspect
    end
  end
end
