require_relative 'check_collection'
require_relative 'database'
require_relative 'results'
require_relative 'exceptions'

module ScoringEngine
  module Engine

    class Machine

      attr_reader :round

      def initialize(checks_location)
        @check_collection = CheckCollection.new(checks_location)
        @database = Database.new(ScoringEngine::Logger)

        previous_round = 0
        recent_checks = Check.order('round DESC')
        unless recent_checks.empty?
          previous_round = recent_checks.first.round
        end

        @round = previous_round
      end

      def testing?
        @testing == true
      end

      def testing
        @testing = true
      end

      def last_round
        @last_round = true
      end

      def last_round?
        @last_round == true
      end

      def stop
        ScoringEngine::Logger.error("Shutting down.")
        if mid_round?
          mid_round_checks = Check.where(:round => @round)
          ScoringEngine::Logger.error("We are mid round, deleting #{mid_round_checks.length} checks from round #{@round}")
          # We need to delete all of the checks that are running and have run this round
          mid_round_checks.each {|c| c.delete}
        end
      end

      def log_check_status
        ScoringEngine::Logger.info("Checks Status:")
        enabled_checks = Check.where(:round => @round)
        checks.each do |check_source|
          check_db_objs = enabled_checks.select{|check| check.service.name == check_source::FRIENDLY_NAME}
          enabled = false
          unless check_db_objs.empty?
            enabled = true
          end

          ScoringEngine::Logger.info("\t#{check_source::FRIENDLY_NAME}: #{enabled}")
        end
      end

      def checks
        @check_collection.checks
      end

      def mid_round?
        @mid_round == true
      end

      def mid_round(result)
        @mid_round = result
      end

      def start(testing = false)
        if testing
          self.testing
        end
        begin
          while !last_round? do
            @round += 1

            Logger.info("Starting new round: #{@round}")
            mid_round(true)
            services = Service.where("enabled = ?", true)
            services.shuffle.each do |service|

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
              check_name = check.class::FRIENDLY_NAME
              Logger.info("Running #{check_name} on #{service.team.name}: #{service.server.name}")

              cmd_str = nil
              begin
                cmd_str = check.command_str
                if cmd_str.nil? or cmd_str.empty?
                  cmd_str = "undefined"
                  raise Exception, "The command_str method returns empty or nil string"
                end
                result,result_info = check.run

              rescue ScoringEngine::Engine::Exceptions::TerminateEngine => e
                raise e
              rescue Exception => e
                cmd_str = "undefined" if cmd_str.nil? or cmd_str.empty?
                Logger.error(e.message + "\n" + e.backtrace.join("\n"))
                result = Failure
                result_info = e.message
              end

              if result == Success
                # cmd_str,result_info = "Check success but with no cmd_str/result_info?...Investigate!" if cmd_str.nil? or result_info.nil?
                result_info = "Expected output received! :)" if result_info.empty?
                Logger.debug("Finished Successfully: #{check_name} for #{service.team.name}: #{service.server.name}")
                submitted_check = ScoringEngine::Engine.create_check(service, @round, true, cmd_str, result_info) unless self.testing?
              elsif result == Failure
                result_info = "Unexpected output received! :(" if result_info.empty?
                # cmd_str,result_info = "Check failed but with no cmd_str/result_info?...Investigate!" if cmd_str.nil? or result_info.nil?
                Logger.debug("Finished Unsuccessfully: #{check_name} for #{service.team.name}: #{service.server.name}")
                submitted_check = ScoringEngine::Engine.create_check(service, @round, false, cmd_str, result_info) unless self.testing?
              end

              if self.testing?
                if result == ScoringEngine::Engine::Results::Success
                  Logger.info("\tSuccess")
                else
                  Logger.info("\tFailure: #{result_info}")
                end
              elsif submitted_check.id.nil?
                Logger.error("Unable to create check (#{check_name}) for #{service.team.name}: #{service.server.name}")
              end
            end

            mid_round(false)

            unless last_round?
              sleep_timer = Random.rand(5...30)
              Logger.info("Sleeping for #{sleep_timer} seconds inbetween rounds")
              sleep sleep_timer
            end
          end
        end

      rescue ScoringEngine::Engine::Exceptions::TerminateEngine
        Logger.fatal("Received TerminateEngine...shutting down.")
        self.stop
        exit
      end
    end

  end
end