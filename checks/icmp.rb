require 'scoring_engine/check'

require 'net/ping'

module ScoringEngine
  module Checks

    class ICMP < ScoringEngine::Checks::Check

      def run
        ping_host = ::Net::Ping::External.new(self.server_ip)
        if ping_host.ping?
          return Results::Success
        else
          return Results::Failure, ping_host.exception
        end
      end

    end
  end
end