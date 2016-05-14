require 'scoring_engine'
require 'shellwords'

module ScoringEngine
  module Checks

    class FTPUpload < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "FTP Upload"
      PROTOCOL = "ftp"
      VERSION = "ipv4"

      def command_str
        # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
        # -S When used with -s it makes curl show an error message if it fails.
        # -4 Resolve names to IPv4 addresses only
        # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
        # --ftp-pasv Force FTP passive mode (server opens high port for upload connection)
        # --ftp-create-dirs Attempt creation of missing directories in upload (normally fails)
        # -T Upload file or text from STDIN if '-' is used
        cmd = 'curl -s -S -4 -v --ftp-pasv --ftp-create-dirs '

        # User
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username.shellescape
        password = user.password.shellescape

        # Default filename
        filename = get_random_property('filename')
        # filename = service.properties.random('filename') || @cyberengine.defaults.properties.random('filename')
        raise("Missing filename property") unless filename
        filename.gsub!('$USER',username)

        # Upload gets text from STDIN
        cmd.prepend("echo 'cyberengine check' | ")
        cmd << ' -T - '

        # URL
        cmd << " ftp://#{username}:#{password}@#{ip}#{filename}"

        return cmd
      end

    end
  end
end
