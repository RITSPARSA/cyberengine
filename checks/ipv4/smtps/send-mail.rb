require 'scoring_engine'

module ScoringEngine
  module Checks

    class SMTPSSendMail < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "SMTP Send Mail"
      PROTOCOL = "smtp"
      VERSION = "ipv4"

      def command_str
        # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
        # -S When used with -s it makes curl show an error message if it fails.
        # -4 Resolve names to IPv4 addresses only
        # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
        # --mail-from Source mail address user@domain
        # --mail-rcpt Destination mail address user@domain
        cmd = 'curl -s -S -4 -v -k --ssl-reqd '

        # From User
        from_user = get_random_property('from-user')
        from_user = service.users.sample unless from_user

        raise "Missing users" unless from_user
        from_username = from_user.username
        from_password = from_user.password

        # From Domain
        from_domain = service.properties.option('from-domain')
        raise("Missing from-domain property") unless from_domain

        # Add From Email
        cmd << " --mail-from '#{from_username}'@'#{from_domain}' "

        # Rcpt User
        rcpt_user = get_random_property('rcpt-user')
        rcpt_user = service.users.sample unless rcpt_user
        raise "Missing users" unless rcpt_user
        rcpt_username = rcpt_user.username

        # Rcpt Domain
        rcpt_domain = service.properties.option('rcpt-domain')
        raise("Missing rcpt-domain property") unless rcpt_domain

        # Add Rcpt Email
        cmd << " --mail-rcpt '#{rcpt_username}'@'#{rcpt_domain}' "

        # Mail gets text from STDIN
        cmd.prepend("echo 'cyberengine check' | ")
        cmd << ' -T - '

        # URL
        cmd << " smtp://#{from_username}:#{from_password}@#{ip}"

        return cmd
      end

    end
  end
end


