web: bundle exec rackup -p9292 --host 0.0.0.0
worker1: RMQ_SHARD=0 exe/killjoy
worker2: RMQ_SHARD=1 exe/killjoy
worker3: RMQ_SHARD=2 exe/killjoy
worker4: RMQ_SHARD=3 exe/killjoy
