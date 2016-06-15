require 'scoring_engine'
require 'shellwords'

module ScoringEngine
  module Checks

    class POP3Login < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "POP3 Login"
      PROTOCOL = "pop3"
      VERSION = "ipv4"

      def command_str
        # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
        # -S When used with -s it makes curl show an error message if it fails.
        # -4 Resolve names to IPv4 addresses only
        # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
        cmd = 'curl -s -S -4 -v '

        # User
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username.shellescape
        password = user.password.shellescape

        # URL
        cmd << " pop3://#{username}:#{password}@#{ip} "

        return cmd
      end

    end
  end
end
