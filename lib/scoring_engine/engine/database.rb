require 'yaml'
require 'active_record'
require 'active_support'

module ScoringEngine
  module Engine
    class Database

      attr_accessor :connection
      def initialize(logger)
        database = ScoringEngine.database_file
        environments = YAML::load(File.open(database))

        ActiveRecord::Base.logger = logger

        if ENV["RAILS_ENV"]
          config = environments[ENV["RAILS_ENV"]]
        else
          config = environments['development'] || environments['production']
        end
        @connection = ActiveRecord::Base.establish_connection(config)
      end
    end
  end
end
