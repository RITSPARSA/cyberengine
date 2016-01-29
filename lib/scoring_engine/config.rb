require 'yaml'

require 'scoring_engine/exceptions'

module ScoringEngine

  class Config

    def initialize(filename)
      @options = YAML.load_file(filename)
    end

    def [](key)
      unless @options.has_key?(key)
        raise ScoringEngine::Exceptions::ConfigValueNotFound.new(key)
      end
      @options[key]
    end
  end

end