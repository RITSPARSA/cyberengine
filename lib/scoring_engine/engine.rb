require 'scoring_engine/check_collection'
require 'scoring_engine/database'

require 'scoring_engine/results/success'
require 'scoring_engine/results/failure'

module ScoringEngine

  class Engine

    def initialize(checks_location)
      @check_collection = CheckCollection.new(checks_location)
      @database = ScoringEngine::Database.new(ScoringEngine::Logger)
    end

    def start(target_ips)
      (1..10).each do |round|
        Logger.info("Starting new round: #{round}")
        services = Service.where("enabled = ?", true)
        services.each do |service|

          service_checks = @check_collection.available_checks.select{|check| check::FRIENDLY_NAME == service.name}
          if service_checks.empty?
            Logger.error("Not running #{service.name}...check not found")
            next
          end
          if service_checks.length > 1
            Logger.error("Not running #{service.name}...More than 1 check found matching???")
            next
          end

          check = service_checks.first.new(service)
          Logger.info("Running #{check.class.clean_name} on #{service.server.name}")

          begin
            result,reason = check.run
          rescue Exception => e
            result = Results::Failure
            reason = e.message
          end

          if result == Results::Success
            Logger.debug("Finished Successfully: #{check} for #{service}")
            submitted_check = ScoringEngine.create_check(service, round, true, "Abc", reason)
          elsif result == Results::Failure
            Logger.debug("Finished Unsuccessfully: #{check} for #{service}...#{reason}")
            submitted_check = ScoringEngine.create_check(service, round, false, "Abc", reason)
          end
        end
      end
    end

  end

end