require 'scoring_engine'

module ScoringEngine
  module Checks

    class NFSContent < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "NFS Content"
      PROTOCOL = "nfs"
      VERSION = "ipv4"

      def command_str
        cmd = "showmount --no-headers -e #{ip}"
        return cmd
      end

    end
  end
end
