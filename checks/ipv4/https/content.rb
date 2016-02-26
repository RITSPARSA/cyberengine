require 'scoring_engine'

module ScoringEngine
  module Checks

    class HTTPSContent < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "HTTPS Content"
      PROTOCOL = "https"
      VERSION = "ipv4"

      def command_str
        cmd = 'curl -s -S -4 -v -L -k --ssl-reqd '

        useragent = get_random_property("useragent")
        useragent.gsub!("'",'') if useragent
        cmd << " -A '#{useragent}' " if useragent

        uri = get_random_property("uri")
        raise("Missing uri property") unless uri

        cmd << " https://#{ip}#{uri} "

        return cmd
      end

    end
  end
end