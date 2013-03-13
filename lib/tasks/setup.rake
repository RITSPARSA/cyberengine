namespace :cyberengine do
  task :setup => :environment do
    Rake::Task["cyberengine:reset"].invoke
    puts ""
    Rake::Task["cyberengine:base"].invoke
    puts ""
    Rake::Task["cyberengine:example"].invoke
  end
end
