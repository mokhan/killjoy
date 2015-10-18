require 'sinatra'
require 'killjoy'

set :bind, '0.0.0.0'
set :port, 9292
set :views, settings.root + '/web/views'

Killjoy::Startup.new(Spank::Container.new).run do |container|
  Spank::IOC.bind_to(container)
  Spank::IOC.resolve(:session).execute("select * from system.hints;")
end

get '/' do
  @logs = Killjoy::CassandraDb
    .from(:log_lines)
    .map_as(Killjoy::LogLine)
  erb :index
end

get '/ip/:ipaddress' do
  @logs = Killjoy::CassandraDb
    .from(:log_lines)
    .where(ipaddress: IPAddr.new(params['ipaddress']))
    .map_as(Killjoy::LogLine)
  erb :index
end

get '/ping' do
  "Hello World!"
end
