require_relative 'check_collection'
require_relative 'database'
require_relative 'results'

module ScoringEngine
  module Engine

    class Machine

      def initialize(checks_location)
        @check_collection = CheckCollection.new(checks_location)
        @database = Database.new(ScoringEngine::Logger)
      end

      def start
        previous_round = 0
        recent_checks = Check.order('round DESC')
        unless recent_checks.empty?
          previous_round = recent_checks.first.round
        end

        round = previous_round
        while true do
          round += 1
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
            Logger.info("Running #{check.class.clean_name} on #{service.team.name}: #{service.server.name}")

            begin
              result,reason = check.run
            rescue Exception => e
              result = Failure
              reason = e.message
            end

            if result == Success
              reason = "Check success for no reason?...Investigate!" if reason.nil?
              Logger.debug("Finished Successfully: #{check.class.clean_name} for #{service.team.name}: #{service.server.name}")
              submitted_check = ScoringEngine::Engine.create_check(service, round, true, "Abc", reason)
            elsif result == Failure
              reason = "Check failed for no reason?...Investigate!" if reason.nil?
              Logger.debug("Finished Unsuccessfully: #{check.class.clean_name} for #{service.team.name}: #{service.server.name}...#{reason}")
              submitted_check = ScoringEngine::Engine.create_check(service, round, false, "Abc", reason)
            end

            if submitted_check.id.nil?
              Logger.error("Unable to create check (#{check.class.clean_name}) for #{service.team.name}: #{service.server.name}")
            end
          end

          Logger.debug("Sleeping for 5 seconds inbetween rounds")
          sleep 5
        end
      end

    end

  end
end