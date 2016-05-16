require 'scoring_engine'
require 'shellwords'

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
        username = user.username.shellescape
        password = user.password.shellescape

        # Default filename
        filename = get_random_property('filename')
        raise("Missing filename property") unless filename
        filename.gsub!('$USER',username)

        # Domain
        domain = get_random_property('domain')
        raise("Missing domain property") unless domain

        cmd << " #{domain}\\#{username}:#{password} smb://#{ip}#{filename}"

        return cmd
      end

    end
  end
end
