class Cyberengine
  # Basic
  require 'logger'
  require 'active_record'
  require 'active_support'

  # Logging
  require_relative 'logging/multi_io'
  require_relative 'logging/pretty_formatter'
  
  # ActiveRecord models
  require_relative 'models/team'
  require_relative 'models/server'
  require_relative 'models/service'
  require_relative 'models/property'
  require_relative 'models/user'
  require_relative 'models/check'

  # Service queries
  require_relative 'services/accessors'


  attr_accessor :logger, :connection
  def initialize(*logdevs)
    # Setup logging
    @logger = Logger.new MultiIO.new(*logdevs)
    @logger.formatter = PrettyFormatter.new
    ActiveRecord::Base.logger = @logger

    database = File.dirname(__FILE__) + '/../database.yml'
    config = YAML::load File.open(database)
  
    # Default to production then development
    if config['production'] 
      config = config['production']
    elsif config['development'] 
      config = config['development']
    end

    # Connect to database
    @connection = ActiveRecord::Base.establish_connection(config)
  end
end
