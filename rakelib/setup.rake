namespace :scoringengine do
  task :setup => :environment do
    Rake::Task["scoringengine:reset"].invoke
    puts ""
    Rake::Task["scoringengine:whiteteam"].invoke
    puts ""
    Rake::Task["scoringengine:redteam"].invoke
    puts ""
    Rake::Task["scoringengine:example"].invoke
  end
end
