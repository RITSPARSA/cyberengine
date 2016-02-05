require 'scoring_engine'

require 'net/ping'

module ScoringEngine
  module Checks

    class ICMP < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "ICMP Ping"
      PROTOCOL = "icmp"
      VERSION = "ipv4"

      def run
        ip_properties = service.properties.select{|property| property.category == "address" and property.property == "ip"}
        if ip_properties.length > 1 or ip_properties.length < 1
          return Failure, "More than 1 ip property defined"
        end
        ip = ip_properties.first.value
        ping_host = ::Net::Ping::External.new(ip)

        if ping_host.ping?
          return Success, ip
        else
          return Failure, ping_host.exception
        end
      end

    end
  end
end