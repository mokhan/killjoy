require "rspec/core/rake_task"
import "lib/killjoy/tasks/db.rake"
import "lib/killjoy/tasks/mongo.rake"
import "lib/killjoy/tasks/rabbitmq.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :timing => ['rabbitmq:reset', 'mongo:drop', 'db:reset'] do
  sh "exe/killjoy-timing"
end
