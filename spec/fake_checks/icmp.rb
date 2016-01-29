require 'scoring_engine'

module ScoringEngine
  module Checks

    class ICMP < ScoringEngine::Checks::BaseCheck

      def run
        return Results::Success
      end

    end
  end
end