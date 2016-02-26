require 'scoring_engine'

module ScoringEngine
  module Checks

    class HTTPAvailable < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "HTTP Available"
      PROTOCOL = "http"
      VERSION = "ipv4"

      def command_str
        cmd = 'curl -s -S -4 -v -L '

        useragent = get_random_property("useragent")
        useragent.gsub!("'",'') if useragent
        cmd << " -A '#{useragent}' " if useragent

        uri = get_random_property("uri")
        raise("Missing uri property") unless uri

        cmd << " http://#{ip}#{uri} "

        return cmd
      end

    end
  end
end