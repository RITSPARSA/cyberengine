require 'scoring_engine'

require 'net/http'
require 'uri'

module ScoringEngine
  module Checks

    class HTTPS < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "HTTPS Available"

      def run
        uri = URI.parse("https://google.com/")

        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = https.get("/")

        if response
          return Success, uri
        else
          return Failure, 'Failed HTTPS for unknown reason'
        end
      end

    end
  end
end