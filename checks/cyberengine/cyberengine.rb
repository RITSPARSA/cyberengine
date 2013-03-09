class Cyberengine
  # Basic
  require 'logger'
  require 'erb' # For URL escaping
  require 'shellwords' # For shell escaping
  require 'timeout' # Check timeouts
  require 'pty' # Executing commands
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


  attr_accessor :logger, :connection, :timeout
  def initialize(*logdevs)
    # Check timeout
    @timeout = 2

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


  def clear_color 
    # Return "clear color" code
    "\e[0m"
  end


  def start_color(color)
    # Format color to equal map
    color.downcase! if color.is_a?(String)
    color = color.to_sym unless color.is_a?(Symbol)
   
    # Color map 
    color_to_integer_map = { black: 30, red: 31, green: 32, yellow: 33, blue: 34, magenta: 35, cyan: 36, white: 37 }
    color = :white unless color_to_integer_map[color]
 
    # Return color
    "\e[#{color_to_integer_map[color]}m"
  end


  def filename
    Time.now.strftime('%Y-%m-%d-%H-%M-%S').prepend('cyberengine-')
  end


  def shellcommand(command)
    response = ''
    begin
      Timeout::timeout(@timeout) do
        PTY.spawn("#{command} 2>&1") do |stdout, stdin, pid|
          begin
            stdout.each { |line| response << line.strip.concat("\r\n") }
          rescue Errno::EIO => exception # Benign error
          end
        end
      end
    rescue Timeout::Error => exception
      response << "Check exceeded #{@timeout} second timeout" 
    rescue Exception => exception
      message = exception.message.empty? ? 'None' : exception.message
      response << "Shell exection exception - Type: #{exception.class} - Message: #{message}"
    end
    response
  end


  def exception_handler(service,exception)
    team = service.team.alias
    service = service.name
    logs = Array.new
    logs << "Exception #{exception.class} raised during check - Team: #{team} - Service: #{service}"
    logs << "Exception message: #{exception.message}"
    logs << "Exception backtrace: #{exception.backtrace}"
    logs.each do |log|
      @logger.error { log }
    end
  end


  def create_check(service,round,passed,request,response)
    check = Hash.new
    check[:team_id] = service.team_id
    check[:server_id] = service.server_id
    check[:service_id] = service.id
    check[:round] = round
    check[:passed] = passed
    check[:request] = request
    check[:response] = response
    Check.create(check)
  end

end

# Encoding passwords and usernames 
class String
  def url_encode
    ERB::Util.url_encode(self)
  end
end
