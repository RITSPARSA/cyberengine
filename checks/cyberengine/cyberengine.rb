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

  attr_accessor :logger, :connection, :whiteteam
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

    # Need whiteteam to find defaults
    @whiteteam = Team.find_by_name('Whiteteam')
  end


  def defaults(name, version, protocol)
    Service.where('team_id = ? AND name = ? AND version = ? AND protocol = ? AND enabled = ?', @whiteteam.id, name, version, protocol, false).first
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

  module SafePty
    def self.spawn(command,&block)
      PTY.spawn(command) do |stdout, stdin, pid|
        begin
          yield stdout,stdin,pid
        rescue Errno::EIO => exception# Benign errors
        ensure
          Process.wait pid
        end
      end
      $?.exitstatus # Return exit status
    end
  end

  def shellcommand(command,service,defaults)
    response = ''
    timeout = service.properties.option('timeout') || defaults.properties.option('timeout')
    raise("Missing timeout property") unless timeout
    timeout = timeout.to_f
    @logger.debug { "Command: #{command}" }
    @logger.debug { "Timeout: #{timeout}" }
    begin
      Timeout::timeout(timeout) do
        SafePty.spawn("#{command} 2>&1") do |stdout, stdin, pid|
          @logger.debug { "PID: #{pid}" }
          stdout.each_line { |line| response << line.strip.concat("\r\n") }
        end
      end
    rescue Timeout::Error => exception
      response << "Check exceeded #{timeout} second timeout" 
    rescue Exception => exception
      message = exception.message.empty? ? 'None' : exception.message
      raise "Shell command exection exception - Type: #{exception.class} - Message: #{message} - Command: #{command}"
    end
    response ? response : "No Response"
  end


  def exception_handler(service,exception)
    logs = Array.new
    logs << "Exception #{exception.class} raised during check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name}"
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

  def services(name, version, protocol)
    # Get services
    blueteams = Team.blueteams.map{|t| t.id }
    services = Service.where('team_id IN (?) AND name = ? AND version = ? AND protocol = ? AND enabled = ?', blueteams, name, version, protocol, true)

    # Convert from ActiveRecord::Relation to Array
    services = services.map{|s| s }

    # Return services
    services
  end

end

# Encoding passwords and usernames 
class String
  def url_encode
    ERB::Util.url_encode(self)
  end
  def timestamped
    self << '-' << Time.now.strftime('%Y-%m-%d-%H-%M-%S')
  end
end
