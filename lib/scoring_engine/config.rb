require 'yaml'

module ScoringEngine

  class Config

    def initialize(filename)
      @options = YAML.load_file(filename)
    end

    def [](key)
      @options[key]
    end

    def to_s
      @options
    end

  end

end