require_relative 'check_collection'
require_relative 'database'
require_relative 'results'
require_relative 'exceptions'

require 'redis'

module ScoringEngine
  module Engine

    class Machine

      CHECK_MAX_TIMEOUT = 20

      attr_reader :round

      def initialize(checks_location)
        @check_collection = CheckCollection.new(checks_location)
        @database = Database.new(ScoringEngine::Logger)

        begin
          ScoringEngine::Logger.info("Connecting to Redis...")
          r = Redis.new
          r.ping
        rescue Errno::ECONNREFUSED,Redis::CannotConnectError => e
          ScoringEngine::Logger.error("Error: Redis server unavailable. Shutting down...")
          exit 1
        end

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

      def checks_running?(checks)
        checks.any?{|check, redis_check|
          redis_check["status"] == "working" or redis_check["status"] == "queued"
        }
      end

      def finished_checks(checks)
        checks.select{|check, redis_check|
          redis_check["status"] != "working" and redis_check["status"] != "queued"
        }
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
            services = Service.where("enabled = ?", true).order('name').order('id')

            check_ids = {}
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
              check_name = check.class::FRIENDLY_NAME

              cmd_str = nil

              cmd_str = check.command_str
              if cmd_str.nil? or cmd_str.empty?
                cmd_str = "undefined"
                raise Exception, "The command_str method returns empty or nil string"
              end

              service_name = service.team.name
              server_name = service.server.name
              Logger.info("Queueing #{check_name} on #{service_name}: #{server_name}")
              job_id = ScoringEngine::Engine::WorkUnit.create(cmd: cmd_str, round: @round)
              check_ids[job_id] = check
            end

            saved_checks = []
            loop do
              check_objs = {}
              check_ids.each {|id,check| check_objs[check] = Resque::Plugins::Status::Hash.get(id)}

              num_completed = check_objs.select{|check, thread_check| thread_check["status"] == "completed"}.length
              num_running = check_objs.select{|check, thread_check| thread_check["status"] == "working"}.length
              num_waiting = check_objs.select{|check, thread_check| thread_check["status"] == "queued"}.length
              num_failed = check_objs.select{|check, thread_check| thread_check["status"] == "failed"}.length
              num_killed = check_objs.select{|check, thread_check| thread_check["status"] == "killed"}.length
              num_saved = saved_checks.length

              puts "Waiting for round of checks to be completed..."
              puts "\tCompleted: #{num_completed}"
              puts "\tRunning: #{num_running}"
              puts "\tWaiting: #{num_waiting}"
              puts "\tFailed: #{num_failed}"
              puts "\tSaved: #{num_saved}"
              puts "\tKilled: #{num_killed}"
              puts "\tTotal: #{check_objs.length}"
              puts ""

              finished_checks(check_objs).each do |check_obj, finished_check|
                unless saved_checks.include?(finished_check["uuid"])
                  output = finished_check["output"]
                  if finished_check.killed? and output.nil?
                    output = "Check exceeded time limit"
                    result = Failure
                  else
                    output = "No output returned." if output.nil? or output.empty?
                    result = check_obj.match?(output)
                  end

                  if result == Success
                    Logger.info("Finished Successfully: #{check_obj.service.name} for #{check_obj.service.team.name}: #{check_obj.service.server.name}")
                  elsif result == Failure
                    Logger.info("Finished Unsuccessfully: #{check_obj.service.name} for #{check_obj.service.team.name}: #{check_obj.service.server.name}")
                  end

                  submitted_check = ScoringEngine::Engine.create_check(check_obj.service, @round, result == Success, finished_check["options"]["cmd"], output)
                  if submitted_check.nil? or submitted_check.id.nil?
                    Logger.fatal("Cannot save check for (#{check_obj.service.name}) for #{check_obj.service.team.name}: #{check_obj.service.server.name}")
                  end

                  saved_checks << finished_check["uuid"]
                end
              end

              sleep 1
              break unless checks_running?(check_objs)
            end

            mid_round(false)
            Logger.info("Finished running checks for round #{@round}")

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