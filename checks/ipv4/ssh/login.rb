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

        cmd = "expect -c 'spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no #{username}@#{ip} #{command}; expect \"assword\"; send \"#{password}\r\"; interact'"

        return cmd
      end

    end
  end
end


