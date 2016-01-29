module ScoringEngine
  module Checks
    class BaseCheck
      attr_reader :service

      def initialize(service)
        @service = service
      end


      def self.clean_name
        return self.name.split("::").last
      end

    end
  end
end