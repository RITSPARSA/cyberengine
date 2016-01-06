module ScoringEngine
  module Checks
    class Check
      attr_reader :service, :server_ip

      def initialize(server_ip)
        @server_ip = server_ip
      end


      def self.clean_name
        return self.name.split("::").last
      end

    end
  end
end