namespace :cyberengine do
  task :setup => :environment do
    Rake::Task["cyberengine:reset"].invoke
    puts ""
    Rake::Task["cyberengine:whiteteam"].invoke
    puts ""
    Rake::Task["cyberengine:redteam"].invoke
    puts ""
    Rake::Task["cyberengine:example"].invoke
  end
end
