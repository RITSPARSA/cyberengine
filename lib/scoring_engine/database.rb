require 'yaml'
require 'active_record'
require 'active_support'

require_relative 'models/team'
require_relative 'models/server'
require_relative 'models/service'
require_relative 'models/property'
require_relative 'models/user'
require_relative 'models/check'

module ScoringEngine
  class Database

    attr_accessor :connection
    def initialize(logger)
      database = ScoringEngine.database_file
      environments = YAML::load(File.open(database))

      ActiveRecord::Base.logger = logger

      config = environments['development'] || environments['production']
      @connection = ActiveRecord::Base.establish_connection(config)
    end
  end
end
