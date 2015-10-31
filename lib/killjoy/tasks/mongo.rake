namespace :mongo do
  desc 'drop database'
  task :drop do
    `mongo killjoy --eval "db.dropDatabase()"`
  end
end
