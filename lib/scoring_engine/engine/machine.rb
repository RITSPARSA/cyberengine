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
              cmd_str = check.command_str
              result,result_info = check.run
            rescue Exception => e
              result = Failure
              result_info = e.message
            end

            if result == Success
              cmd_str,result_info = "Check success but with no cmd_str/result_info?...Investigate!" if cmd_str.nil? or result_info.nil?
              Logger.debug("Finished Successfully: #{check.class.clean_name} for #{service.team.name}: #{service.server.name}")
              submitted_check = ScoringEngine::Engine.create_check(service, round, true, cmd_str, result_info)
            elsif result == Failure
              cmd_str,result_info = "Check failed but with no cmd_str/result_info?...Investigate!" if cmd_str.nil? or result_info.nil?
              Logger.debug("Finished Unsuccessfully: #{check.class.clean_name} for #{service.team.name}: #{service.server.name}")
              submitted_check = ScoringEngine::Engine.create_check(service, round, false, cmd_str, result_info)
            end

            if submitted_check.id.nil?
              Logger.error("Unable to create check (#{check.class.clean_name}) for #{service.team.name}: #{service.server.name}")
            end
          end

          sleep_timer = Random.rand(5...30)
          Logger.info("Sleeping for #{sleep_timer} seconds inbetween rounds")
          sleep sleep_timer
        end
      end

    end

  end
end