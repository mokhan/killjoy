namespace :rabbitmq do
  desc 'setup rabbitmqadmin'
  task :setup do
    sh "wget http://127.0.0.1:15672/cli/rabbitmqadmin"
    sh "chmod 777 rabbitmqadmin"
    sh "sudo mv rabbitmqadmin /usr/local/bin/"
  end

  desc "create admin user"
  task :admin do
    # https://stackoverflow.com/questions/23020908/how-to-access-rabbitmq-publicly
    sh "sudo rabbitmqctl add_user admin admin"
    sh 'sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"'
    sh 'sudo rabbitmqctl set_user_tags admin administrator'
  end

  desc "create sharded exchange."
  task :create do
    sh "rabbitmqadmin declare exchange --vhost=/ name=killjoy type=x-modulus-hash"
    sh "sudo rabbitmqctl set_policy killjoy-shard \"^killjoy$\" '{\"shards-per-node\": 4, \"routing-key\": \"#\"}' --apply-to exchanges"
  end

  desc "delete sharded exchange."
  task :drop do
    sh "sudo rabbitmqctl stop_app"
    sh "sudo rabbitmqctl reset"
    sh "sudo rabbitmqctl start_app"
  end

  desc 'reset rabbitmq'
  task :reset => [:drop, :admin, :create]
end
