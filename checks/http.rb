require 'scoring_engine/check'

require "net/http"
require "uri"

module ScoringEngine
  module Checks

    class HTTP < ScoringEngine::Checks::Check

      def run
        uri = URI.parse("http://#{self.server_ip}")

        response = Net::HTTP.get_response(uri)
        if response
          return Results::Success
        else
          return Results::Failure, "Failed http"
        end
      end

    end
  end
end