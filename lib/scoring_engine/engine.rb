# require 'plugman'
# require 'threadpool'
require 'scoring_engine/check_collection'

require 'scoring_engine/results/success'
require 'scoring_engine/results/failure'

module ScoringEngine

  class Engine

    THREADPOOL_NUMBER = 2

    def initialize(checks_location)
      @check_collection = CheckCollection.new(checks_location)
      @check_collection.load
    end

    def start(target_ip)
      @check_collection.available_checks.each do |check_class_name|
        name = check_class_name.clean_name
        Logger.debug("Loading #{name} for #{target_ip}")
        check = check_class_name.new(target_ip)
        Logger.debug("Running #{name} for #{target_ip}")

        begin
          result,reason = check.run
        rescue Exception => e
          result = Results::Failure
          reason = e.message
        end

        if result == Results::Success
          Logger.debug("Finished Successfully: #{name} for #{target_ip}")
        elsif result == Results::Failure
          Logger.debug("Finished Unsuccessfully: #{name} for #{target_ip}...#{reason}")
        else
          Logger.error("#{name} finished with unknown result: #{result} reason: #{reason}")
        end
      end

    end

  end

end