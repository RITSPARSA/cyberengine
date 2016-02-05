require 'scoring_engine'

require 'net/http'
require 'uri'

module ScoringEngine
  module Checks

    class HTTP < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "HTTP Available"

      def run
        uri = URI.parse("http://google.com")
        response = Net::HTTP.get_response(uri)
        if response
          return Success, uri
        else
          return Failure, 'Failed http'
        end
      end

    end
  end
end