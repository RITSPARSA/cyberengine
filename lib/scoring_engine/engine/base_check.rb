include ScoringEngine::Engine::Results

require 'pty'

module ScoringEngine
  module Engine

    class BaseCheck
      attr_reader :service

      def initialize(service)
        @service = service
      end

      def execute_command(command_str)
        output = ""
        PTY.spawn(command_str) do |irb_out, irb_in, pid|
          output = irb_out.readlines.join("")
        end
        return output
      end

      def get_random_property(key)
        unless defaults.nil?
          useragent = defaults.properties.where(:property => key).sample.value unless defaults.properties.where(:property => key).empty?
        end

        useragent = service.properties.where(:property => key).sample.value unless service.properties.where(:property => key).empty?

        return useragent
      end

      def ip
        ip_addresses = service.properties.addresses
        if ip_addresses.length > 1 or ip_addresses.length < 1
          raise MultipleIPProperties, ip_addresses
        end
        return ip_addresses.first
      end

      def get_preferred_match_regex
        regex = defaults.properties.answer('each-line-regex')
        regex = service.properties.answer('each-line-regex') unless service.properties.answer('each-line-regex').empty?
        if regex.nil?
          regex = defaults.properties.answer('full-line-regex')
          regex = service.properties.answer('full-line-regex') unless service.properties.answer('full-line-regex').empty?
        end
        raise "Missing answer property: each-line-regex or full-text-regex required" unless regex

        return regex
      end

      def match?(output)
        if output.match(get_preferred_match_regex)
          return Success, @response
        else
          return Failure, @response
        end
      end

      def run
        @request = command_str.strip.squeeze(' ')

        @response = execute_command(@request)

        return match?(@response)
      end

      def self.clean_name
        return self.name.split("::").last
      end

      def defaults
        whiteteam = Team.find_by_name('Whiteteam')
        name = self.class::FRIENDLY_NAME
        version = self.class::VERSION
        protocol = self.class::PROTOCOL
        Service.where('team_id = ? AND name = ? AND version = ? AND protocol = ? AND enabled = ?', whiteteam.id, name, version, protocol, false).first
      end

    end
  end
end