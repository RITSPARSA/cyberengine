# Connects to Cyberengine database as outlined in database.yml
# Default: production
# Backup: development
module Cyberengine
  class Database
    require 'active_record'
    require 'active_support'
  
    # Cyberengine ActiveRecord models
    require_relative 'models/team'
    require_relative 'models/server'
    require_relative 'models/service'
    require_relative 'models/property'
    require_relative 'models/user'
    require_relative 'models/check'
  
    # Connect to database
    attr_accessor :connection
    def initialize(logger)
      # Get database information
      database = Cyberengine.database_file
      environments = YAML::load(File.open(database))
  
      # Setup logger
      ActiveRecord::Base.logger = logger
  
      # Default to production then development
      config = environments['development'] || environments['production']
      @connection = ActiveRecord::Base.establish_connection(config)
    end
  end
end
