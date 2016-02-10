require 'scoring_engine'

module ScoringEngine
  module Checks

    class FTPDownload < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "FTP Download"
      PROTOCOL = "ftp"
      VERSION = "ipv4"

      def command_str
        cmd = 'curl -s -S -4 -v --ftp-pasv '

        # User
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username
        password = user.password

        # Default filename
        filename = get_random_property('filename')
        raise("Missing filename property") unless filename
        filename.gsub!('$USER',username)

        # URL
        cmd << " ftp://#{username}:#{password}@#{ip}#{filename}"

        return cmd
      end

    end
  end
end