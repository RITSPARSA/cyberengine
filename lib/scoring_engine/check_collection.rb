module ScoringEngine

  class CheckCollection

    attr_reader :checks_location, :available_checks
    def initialize(checks_location)
      @checks_location = checks_location
    end


    def load
      @available_checks = []

      Dir.glob("#{self.checks_location}/*.rb").each do |check_file|
        require_relative check_file
      end

      ScoringEngine::Checks.constants.each do |check|
        # The default parent class
        next if check == :Check

        @available_checks << Object.const_get("ScoringEngine::Checks::#{check}")
      end
    end

  end
end