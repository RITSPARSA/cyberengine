require 'scoring_engine'

module ScoringEngine
  module Checks

    class SSHLogin < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "SSH Login"
      PROTOCOL = "ssh"
      VERSION = "ipv4"

      def command_str
        user = service.users.sample
        raise "Missing users" unless user
        username = user.username
        password = user.password

        command = get_random_property("command")
        raise "Missing command" unless command
        cmd = "ssh #{username}:#{password}@#{ip} '#{command}'"

        return cmd
      end

    end
  end
end


