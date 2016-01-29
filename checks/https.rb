require 'scoring_engine'

require 'net/http'
require 'uri'

module ScoringEngine
  module Checks

    class HTTPS < ScoringEngine::Checks::BaseCheck

      FRIENDLY_NAME = "HTTPS Available"

      def run
        uri = URI.parse("https://google.com/")

        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = https.get("/")

        if response
          return Results::Success, uri
        else
          return Results::Failure, 'Failed HTTPS for unknown reason'
        end
      end

    end
  end
end