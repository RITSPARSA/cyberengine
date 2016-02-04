namespace :cyberengine do
  task :reset => :environment do
    puts "Dropping database"
    Rake::Task["db:drop"].invoke

    puts "Creating database"
    Rake::Task["db:create"].invoke

    puts "Migrating database schema"
    Rake::Task["db:migrate"].invoke
  end
end
