require 'scoring_engine'

module ScoringEngine
  module Checks

    class POP3SLogin < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "POP3S Login"
      PROTOCOL = "pop3s"
      VERSION = "ipv4"

      def command_str
        # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
        # -S When used with -s it makes curl show an error message if it fails.
        # -4 Resolve names to IPv4 addresses only
        # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
        cmd = 'curl -s -S -4 -v -k --ssl-reqd '

        # User
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username
        password = user.password

        # URL
        cmd << " pop3://#{username}:#{password}@#{ip} "

        return cmd
      end

    end
  end
end