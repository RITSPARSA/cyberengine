require 'scoring_engine'

module ScoringEngine
  module Checks

    class DNSDomainQuery < ScoringEngine::Engine::BaseCheck

      FRIENDLY_NAME = "DNS Domain Query"
      PROTOCOL = "dns"
      VERSION = "ipv4"

      def command_str
        # @<ip> DNS server address
        # -t Type of request - PTR, A, or AAAA
        # -q Domain to perform query for
        cmd = "dig @#{ip} "

        # query-type
        query_type = get_random_property('query-type')
        # query_type = service.properties.option('query-type')
        raise("Missing query-type property") unless query_type

        # query
        query = get_random_property('query')
        # query = service.properties.random('query')
        raise("Missing query property") unless query

        # Build cmd
        cmd << " -t #{query_type} -q #{query} "

        return cmd
      end

    end
  end
end