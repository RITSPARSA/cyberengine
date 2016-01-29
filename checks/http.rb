require 'scoring_engine'

require 'net/http'
require 'uri'

module ScoringEngine
  module Checks

    class HTTP < ScoringEngine::Checks::BaseCheck

      FRIENDLY_NAME = "HTTP Available"

      def run
        uri = URI.parse("http://google.com")
        response = Net::HTTP.get_response(uri)
        if response
          return Results::Success, uri
        else
          return Results::Failure, 'Failed http'
        end
      end

    end
  end
end