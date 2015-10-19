require 'killjoy'
require 'sinatra'
require 'tilt/erb'

set :bind, '0.0.0.0'
set :port, 9292
set :views, settings.root + '/web/views'

Killjoy::Startup.new(Spank::Container.new).run do |container|
  Spank::IOC.bind_to(container)
  Spank::IOC.resolve(:session).execute("select * from system.hints;")
end

helpers do
  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  @logs = Killjoy::LogLine.all
  erb :index
end

get '/ip/:ipaddress' do
  @ipaddress = IPAddr.new(params['ipaddress'])
  @logs = Killjoy::LogLine.from_ip(@ipaddress)
  erb :index
end

get '/ping' do
  message = Killjoy::LogLine.new(
    http_status: 200,
    http_verb: request["REQUEST_METHOD"],
    http_version: request["SERVER_PROTOCOL"],
    ipaddress: request["REMOTE_HOST"],
    timestamp: DateTime.now.to_time.to_i,
    url: request["PATH_INFO"],
    user_agent: request["HTTP_USER_AGENT"],
  )
  Killjoy::Publisher.new.publish(message)

  "Hello World!"
end
