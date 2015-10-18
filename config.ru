require "bundler/setup"
$LOAD_PATH.unshift(File.join(Dir.pwd, "lib"))
require "killjoy/web"

run Sinatra::Application
