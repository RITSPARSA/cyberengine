require 'scoring_engine'

module ScoringEngine
  module Checks

    class NFSAvailable < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "NFS Available"
      PROTOCOL = "nfs"
      VERSION = "ipv4"

      def command_str
        port = 2049
        cmd = "curl -m 3 -s #{ip}:#{port} > /dev/null && echo OK || echo NOK"
        return cmd
      end

    end
  end
end
