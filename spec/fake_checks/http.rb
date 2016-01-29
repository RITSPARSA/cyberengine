require 'scoring_engine'


module ScoringEngine
  module Checks

    class HTTP < ScoringEngine::Checks::BaseCheck

      def run
        return Results::Failure, "Example error output"
      end

    end
  end
end