require_relative 'checker'
require_relative 'database'
require_relative 'logging/logging'

module Cyberengine
  def checkify(file,args=[],options={})
    check = Hash.new
    check[:path] = File.expand_path(file)
    check[:version] = path_version(check[:path])
    check[:protocol] = path_protocol(check[:path])
    check[:basename] = path_basename(check[:path])
    check[:name] = check[:protocol].upcase + ' ' + path_name(check[:path])
    check[:id] = "#{check[:version]}/#{check[:protocol]}/#{check[:basename]}"
    check[:test] = args.include?('test') ? true : false
    check[:daemon] = args.include?('daemon') ? true : false
    check[:delay] = options[:delay].to_i <= 5 ? 5 : options[:delay].to_i 
    check[:pid_dir] = Cyberengine.pid_dir + "/#{check[:version]}/#{check[:protocol]}"
    check[:log_dir] = Cyberengine.log_dir + "/#{check[:version]}/#{check[:protocol]}"
    check[:pid_file] = check[:pid_dir] + "/#{check[:basename]}.pid"
    check[:log_file] = check[:log_dir] + "/#{check[:basename]}.log"
    check[:enabled] = check[:path] !~ check_disable_regex
    check[:disabled] = check[:path] =~ check_disable_regex
    check
  end

  def path_version(path) path.split('/')[-3] end
  def path_protocol(path) path.split('/')[-2] end
  def path_basename(path) File.basename(path).split('.').first end
  def path_name(path) path_basename(path).split('-').map {|w| w.capitalize }.join(' ') end

  def check_id(check) check[:id] end
  def check_delay(check) check[:delay] end
  def check_name(check) check[:name] end
  def check_version(check) check[:version] end
  def check_protocol(check) check[:protocol] end
  def check_test(check) check[:test] end
  def check_daemon(check) check[:daemon] end
  def check_log_dir(check) check[:log_dir] end
  def check_pid_dir(check) check[:pid_dir] end
  def check_log_file(check) check[:log_file] end
  def check_pid_file(check) check[:pid_file] end
  def check_enabled?(check) check[:enabled] end
  def check_disabled?(check) check[:disabled] end
  def check_disable_regex; /\.disabled?\z/ end
  def check_disable_text; '.disabled' end

  def root_dir; File.dirname(File.expand_path(File.dirname(__FILE__))) end
  def checks_dir; Cyberengine.root_dir + '/checks' end
  def setup_dir; Cyberengine.root_dir + '/setup' end
  def log_dir; Cyberengine.root_dir + '/logs' end
  def pid_dir; Cyberengine.root_dir + "/pids" end
  def database_file; Cyberengine.setup_dir + '/database.yml' end

  def clear_color; "\e[0m" end
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

  # Detach and become daemon
  def daemonize(check)
    return get_pid(check) if get_pid(check)
    Process.daemon
    File.open(check_pid_file(check),'w') {|file| file.write(Process.pid) }
    false # Anything but false means failure
  end


  def get_pid(check)
    pid_file = Cyberengine.check_pid_file(check)
    if File.exists?(pid_file) && File.readable?(pid_file)
      pid = File.read(pid_file).to_i
      begin
        Process.getpgid(pid) # PID in use? (raises Errno::ESRCH)
        return pid # Return non-false value
      rescue Errno::ESRCH
      end
    end
    false
  end

  # Simple PTY module to help execute commands  
  module SafePty
    def self.spawn(command,&block)
      PTY.spawn(command.to_s + ' 2>&1') do |stdout, stdin, pid|
        begin
          yield stdout,stdin,pid
        rescue Errno::EIO => exception # Benign errors
        end
      end
      return 1
    end
  end

  # Run command yielding output
  def shellexecute(command)
    SafePty.spawn(command) do |stdout, stdin, pid|
      stdout.each_line { |line| yield line }
    end
  end

  # Check running?
  def check_running?(check)
    pid = get_pid(check)
    pid ? { status: true, message: "Running with pid #{pid}" } : { status: false, message: "Not running" }
  end

  # Start check in daemon mode and return status hash containing status and a message
  def start_daemon_check(check)
    pid = get_pid(check)
    return { status: false, message: "Already running with pid #{pid}" } if pid
    return { status: false, message: "Check disabled" } if check[:disabled]
    `#{check[:path]} daemon`
    sleep 0.3
    pid = get_pid(check)
    pid ? { status: true, message: "Running with pid #{pid}" } : { status: false, message: "Startup pid lookup unsuccessful" }
  end

  # Start check in test mode and yield output
  def start_test_check(check)
    Cyberengine.shellexecute(check[:path] + ' test') { |line| yield line }
  end

  # Find errors in log files
  def find_check_errors(check)
    log_file = check[:log_file]
    if File.exists?(log_file) && File.readable?(log_file)
      Cyberengine.shellexecute('grep -H -n -v -E "(DEBUG|INFO)" ' + log_file) { |line| yield line }
    else
      puts "Skipping #{check[:id]} because #{log_file} does not exist"
    end
  end
  
  # Stop check in daemon mode and return status hash containing status and a message
  def stop_check(check)
    pid = get_pid(check)
    return { status: false, message: "Check does not appear to be running" } unless pid
    Process.kill('TERM',pid) 
    { status: true, message: "Sent TERM signal to pid #{pid}" }
  end

  # Disable check
  def disable_check(check)
    path = check[:path]
    if File.exists?(path) && File.readable?(path)
      File.rename(path,path + '.disabled') unless check[:disabled]
      return { status: true }
    end
    { status: false, message: "Check path #{path} does not exist or is not readable" }
  end

  # Disable check
  def disable_check(check)
    path = check[:path]
    if File.exists?(path) && File.readable?(path) 
      File.rename(path,path + check_disable_text) unless check[:disabled]
      return { status: true, message: 'Appended ' + check_disable_text + ' to check filename' }
    end
    { status: false, message: "Check path #{path} does not exist or is not readable" }
  end

  # Disable check
  def enable_check(check)
    path = check[:path]
    if File.exists?(path) && File.readable?(path)
      File.rename(path,path.gsub(check_disable_regex,'')) unless check[:enabled]
      return { status: true, message: 'Removed ' + check_disable_text + ' from check filename' }
    end
    { status: false, message: "Check path #{path} does not exist or is not readable" }
  end
 
  def green(message) Cyberengine.start_color(:green) + message.to_s + Cyberengine.clear_color end
  def red(message) Cyberengine.start_color(:red) + message.to_s + Cyberengine.clear_color end
end


require 'erb'
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


include Cyberengine
