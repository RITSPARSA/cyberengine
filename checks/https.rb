require 'scoring_engine/check'

require "net/http"
require "uri"

module ScoringEngine
  module Checks

    class HTTPS < ScoringEngine::Checks::Check

      def run
        uri = URI.parse("https://#{self.server_ip}/")

        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE
        response = https.get("/")

        if response
          return Results::Success
        else
          return Results::Failure, "Failed HTTPS for unknown reason"
        end
      end

    end
  end
end