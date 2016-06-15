require 'scoring_engine'
require 'shellwords'

module ScoringEngine
  module Checks

    class MySQLLogin < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "MySQL Login"
      PROTOCOL = "mysql"
      VERSION = "ipv4"

      def command_str
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username.shellescape
        password = user.password.shellescape

        database = get_random_property("database")
        raise "Missing database" unless database

        command = get_random_property("command")
        raise "Missing command" unless command

        cmd = "mysql -h #{ip} -u #{username} -p#{password} #{database} -e '#{command}'"

        return cmd
      end

    end
  end
end


