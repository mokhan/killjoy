require "rspec/core/rake_task"
require "sneakers/tasks"
import "lib/killjoy/tasks/db.rake"
import "lib/killjoy/tasks/rabbitmq.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
