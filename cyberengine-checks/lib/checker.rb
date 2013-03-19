module Cyberengine
  class Checker
    require 'fileutils'
    require 'shellwords' 
    require 'timeout'
    require 'pty'
  
    attr_reader :id, :check, :name, :delay, :test, :daemon, :logger, :connection, :whiteteam, :pid, :stop
    # Defaults: Cyberengine.checkify
    def initialize(check)
      @check = check
      @id = Cyberengine.check_id(@check)
      @name = Cyberengine.check_name(@check)
      @delay = Cyberengine.check_delay(@check) 
      @test = Cyberengine.check_test(@check)
      @daemon = Cyberengine.check_daemon(@check)

      # Create pid/log paths
      create_path(Cyberengine.check_log_dir(@check))
      create_path(Cyberengine.check_pid_dir(@check))
  
      # Used for signals
      @stop = false

      # Setup logging
      @logger = Cyberengine::Logging.new(@check).logger
  
      # Daemonize
      if @daemon
        pid = Cyberengine.daemonize(@check)
        if pid
          @check[:daemon] = false
          @daemon = false
          @logger.info { "Check #{@id} already running with pid: #{pid}" }
          terminate
        end
        @logger.info { "Successfully daemonized" } 
      end
      @pid = Process.pid
  
      # Database connection
      Cyberengine::Database.new(@logger)

      # Need whiteteam to find defaults
      @whiteteam = Team.find_by_name('Whiteteam')
      raise "Team 'Whiteteam' is required to find defaults" unless @whiteteam
    end

    # Delete pid file 
    def terminate
      pid_file = Cyberengine.check_pid_file(@check)
      File.delete(pid_file) if @daemon && File.exists?(pid_file)
      @logger.info { "Successfully terminated" } 
      @logger.close
      exit
    end

    # Create pid/log paths 
    def create_path(path) FileUtils.mkdir_p(path) unless File.directory?(path) end

    # Trap TERM signal and exit
    def signals
      Signal.trap('TERM') do 
        @logger.info { "Received TERM Signal - Stopping after round" }
        @stop = true
      end
    end

    def defaults
      name = Cyberengine.check_name(@check)
      version = Cyberengine.check_version(@check)
      protocol = Cyberengine.check_protocol(@check)
      Service.where('team_id = ? AND name = ? AND version = ? AND protocol = ? AND enabled = ?', @whiteteam.id, name, version, protocol, false).first
    end
  
    # Run command capturing all output within timeout or command completion 
    def shellcommand(command,service)
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
          Cyberengine::SafePty.spawn(command) do |stdout, stdin, pid|
            @logger.debug { "PID: #{pid}" }
            stdout.each_line { |line| response << line.strip.concat("\r\n") }
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
      response.empty? ? "No Response" : response.strip.concat("\r\n")
    end
  
    # Default exception logger - log error and continue
    def exception_handler(service,exception)
      logs = Array.new
      logs << "Exception #{exception.class} raised during check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name}"
      logs << "Exception message: #{exception.message}"
      logs << "Exception backtrace: #{exception.backtrace}"
      logs.each { |log| @logger.error { log } }
    end
  
    # Fatal exception logger - log and send terminate signal    
    def fatal_exception_handler(exception)
      logs = Array.new
      logs << "Daemon crashed due to #{exception.class}"
      logs << "Exception message: #{exception.message}"
      logs << "Exception backtrace: #{exception.backtrace}"
      logs.each { |log| @logger.fatal { log } }
      Process.kill("TERM", Process.pid)
    end

    # Attempt to create check
    # Destroy check if in testing mode
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
 
     
    # Get services and return in array
    def services
      name = Cyberengine.check_name(@check)
      version = Cyberengine.check_version(@check)
      protocol = Cyberengine.check_protocol(@check)
      blueteams = Team.blueteams.map{|t| t.id }
      services = Service.where('team_id IN (?) AND name = ? AND version = ? AND protocol = ? AND enabled = ?', blueteams, name, version, protocol, true)
      services.map{|s| s }
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
