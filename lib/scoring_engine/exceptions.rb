module ScoringEngine

  module Exceptions

    class ConfigValueNotFound < StandardError

      def initialize(key)
        @key = key
      end

      def message
        "#{@key} must be specified in config file"
      end

    end

  end

end