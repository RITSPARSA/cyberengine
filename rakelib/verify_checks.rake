require 'scoring_engine'

namespace :scoringengine do
  task :verify_checks => :environment do
    puts "Verifying the checks"

    ScoringEngine::Logger.level = Logger::INFO
    collection = ScoringEngine::Engine::CheckCollection.new(ScoringEngine.checks_dir)
    checks = collection.checks
    checks_not_found = false
    Team.all.each do |team|
      team.servers.all.each do |server|
        server.services.all.each do |service|

          found_check = checks.select{|c| c::FRIENDLY_NAME == service.name}
          if found_check.empty?
            ScoringEngine::Logger.error("** #{team.name}:#{server.name}:#{service.name} Check Not Found **")
            checks_not_found = true
          end
        end
      end
    end
    if checks_not_found
      ScoringEngine::Logger.error("----- ERROR - One or many checks could not be linked to their source code. Exiting on failure -----")
      exit 1
    end
  end
end
