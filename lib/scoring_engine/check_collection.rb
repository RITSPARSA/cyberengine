require 'scoring_engine/exceptions'

module ScoringEngine

  class CheckCollection

    attr_reader :checks_location, :available_checks

    def initialize(checks_location)
      unless File.directory?(checks_location)
        raise Exceptions::BadCheckLocation.new("#{checks_location} is invalid")
      else
        @checks_location = checks_location
      end

      @available_checks = []

      Dir.glob("#{self.checks_location}/*.rb").each do |check_file|
        ScoringEngine::Logger.debug("Requiring #{check_file}")
        require_relative check_file
      end

      ScoringEngine::Checks.constants.each do |check|
        # The default parent class
        next if check == :BaseCheck

        @available_checks << Object.const_get("ScoringEngine::Checks::#{check}")
      end
    end

    def checks
      return @available_checks
    end

  end
end