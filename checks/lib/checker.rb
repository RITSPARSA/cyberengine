module Cyberengine
  class Checker
    require 'fileutils'
    require 'shellwords' 
    require 'timeout'
    require 'pty'
  
    attr_reader :check, :name, :path, :delay, :test, :daemon, :logger, :connection, :whiteteam, :pid, :stop
    def initialize(check)
      # {path: 'ipv4', name: 'example', daemon: false }
      @check = check
      @name = Cyberengine.check_name(check)
      @path = Cyberengine.check_path(check)
      @delay = Cyberengine.check_delay(check) 
      @test = Cyberengine.check_test(check)
      @daemon = Cyberengine.check_daemon(check)

      # Create pid/log paths
      create_path(@check)
  
      # Used for signals
      @stop = false
      @delay = 5 if @delay <= 5
  
      # Daemonize
      if @daemon
        pid = Cyberengine.daemonize(@check)
        if pid
          puts "Failed to start #{@path} #{@name} - check already running with pid: #{pid}"
          puts "Stop in Cyberengine: cyberengine stop #{@path} #{@name}"
          puts "Stop in bash: kill -s TERM #{pid}"
          exit
        end
      end
      @pid = Process.pid

      # Setup logging
      @logger = Cyberengine::Logging.new(@check).logger
      @logger.info { "Successfully daemonized" } if @daemon
  
      # Database connection
      Cyberengine::Database.new(logger: @logger)

      # Need whiteteam to find defaults
      @whiteteam = Team.find_by_name('Whiteteam')
      raise "Team 'Whiteteam' is required to find defaults" unless @whiteteam
    end

    # Delete pid file 
    def terminate
      pid_file = Cyberengine.pid_file(@check)
      File.delete(pid_file) if @daemon && File.exists?(pid_file)
      @logger.info { "Successfully terminated" } 
      @logger.close
    end

    # Create pid/log paths 
    def create_path(check)
      pid_dir = Cyberengine.pid_dir(check)
      log_dir = Cyberengine.log_dir(check)
      FileUtils.mkdir_p(pid_dir) unless File.directory?(pid_dir)
      FileUtils.mkdir_p(log_dir) unless File.directory?(log_dir)
    end

    def signals
      Signal.trap('TERM') do 
        @logger.info { "Received TERM Signal - Stopping after round" }
        @stop = true
      end
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
          rescue Errno::EIO => exception # Benign errors
          end
        end
        return 1
      end
    end
  
    def shellcommand(command,service,defaults)
      response = ''
 
      # Check timeout 
      timeout = service.properties.option('timeout') || defaults.properties.option('timeout')
      raise("Missing timeout property") unless timeout
      timeout = timeout.to_f
 
      # Log options
      @logger.debug { "Command: #{command}" }
      @logger.debug { "Timeout: #{timeout}" }
 
      # Run command 
      begin
        Timeout::timeout(timeout) do
          SafePty.spawn("#{command} 2>&1") do |stdout, stdin, pid|
            @logger.debug { "PID: #{pid}" }
            stdout.each_line { |line| response << line }
          end
        end
      rescue Timeout::Error => exception
        response << "Check exceeded #{timeout} second timeout" 
      rescue StandardError => exception
        message = exception.message.empty? ? 'None' : exception.message
        raise "Shell command exection exception - Type: #{exception.class} - Message: #{message} - Command: #{command}"
      end
  
      # Cant insert empty responses into database, so say "No Response"
      # Strip to remove double newlines (HTTP) and replace with one
      response.empty? ? "No Response" : response.strip.concant("\r\n")
    end
  
    # Default exception logger    
    def exception_handler(service,exception)
      logs = Array.new
      logs << "Exception #{exception.class} raised during check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name}"
      logs << "Exception message: #{exception.message}"
      logs << "Exception backtrace: #{exception.backtrace}"
      logs.each do |log|
        @logger.error { log }
      end
    end
  
    # Fatal exception logger    
    def fatal_exception_handler(exception)
      logs = Array.new
      logs << "Daemon crashed due to #{exception.class}"
      logs << "Exception message: #{exception.message}"
      logs << "Exception backtrace: #{exception.backtrace}"
      logs.each do |log|
        @logger.fatal { log }
      end
      terminate
    end

    # Attempt to create check 
    def create_check(service,round,passed,request,response)
      check = Hash.new
      check[:team_id] = service.team_id
      check[:server_id] = service.server_id
      check[:service_id] = service.id
      check[:round] = round
      check[:passed] = passed
      check[:request] = request
      check[:response] = response
      check = Check.create(check)
      check.destroy if Cyberengine.check_test(@check)
      check
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
end
  
class String
  # Encoding passwords and usernames 
  def url_encode
    ERB::Util.url_encode(self)
  end
  
  # Add timestamp to string (filenames)
  def timestamped
    self << '-' << Time.now.strftime('%Y-%m-%d-%H-%M-%S')
  end
end
  
class File
  # Get check's filename
  def myname(file)
    File.basename(file).split('.').first.to_s
  end
end
