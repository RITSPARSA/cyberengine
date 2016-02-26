require 'scoring_engine'

module ScoringEngine
  module Checks

    class SMBDownload < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "SMB Download"
      PROTOCOL = "smb"
      VERSION = "ipv4"

      def command_str
        # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
        # -S When used with -s it makes curl show an error message if it fails.
        # -4 Resolve names to IPv4 addresses only
        # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
        # -u Use username and password
        cmd = 'curl -s -S -4 -v -u'

        # User
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username
        password = user.password

        # User
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username
        password = user.password

        # Default filename
        filename = get_random_property('filename')
        raise("Missing filename property") unless filename
        filename.gsub!('$USER',username)

        cmd << "\"#{username}:#{password}\" smb://#{ip}#{filename}"

        return cmd
      end

    end
  end
end