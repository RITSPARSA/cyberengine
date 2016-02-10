require 'scoring_engine'

module ScoringEngine
  module Checks

    class ICMPPing < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "ICMP Ping"
      PROTOCOL = "icmp"
      VERSION = "ipv4"

      def command_str
        cmd = "ping -n -c 1 #{ip}"

        return cmd
      end

    end
  end
end