require_relative 'exceptions'

include ScoringEngine::Engine::Results

module ScoringEngine
  module Engine

    class BaseCheck
      attr_reader :service

      def initialize(service)
        @service = service
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
          raise Exceptions::MultipleIPProperties, ip_addresses
        end
        return ip_addresses.first
      end

      def get_preferred_match_regex
        regex = defaults.properties.answer('each-line-regex')
        regex = service.properties.answer('each-line-regex') unless service.properties.answer('each-line-regex').empty?
        if regex.empty?
          regex = defaults.properties.answer('full-text-regex')
          regex = service.properties.answer('full-text-regex') unless service.properties.answer('full-text-regex').empty?
        end

        raise "Missing answer property: each-line-regex or full-text-regex required" unless regex

        return regex
      end

      def match?(output)
        if output.match(get_preferred_match_regex)
          return Success
        else
          return Failure
        end
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