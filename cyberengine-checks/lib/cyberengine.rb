require_relative 'checker'
require_relative 'database'
require_relative 'logging/logging'

module Cyberengine
  def checkify(file,args,options={})
    path = File.expand_path(file)
    check = Hash.new
    check[:version] = path_version(path)
    check[:protocol] = path_protocol(path)
    check[:basename] = path_basename(path)
    check[:name] = check[:protocol].upcase + ' ' + path_name(path)
    check[:id] = "#{check[:version]}/#{check[:protocol]}/#{check[:basename]}"
    check[:test] = args.include?('test') ? true : false
    check[:daemon] = args.include?('daemon') ? true : false
    check[:delay] = options[:delay].to_i <= 5 ? 5 : options[:delay].to_i 
    check[:pid_dir] = Cyberengine.pid_dir + "/#{check[:version]}/#{check[:protocol]}"
    check[:log_dir] = Cyberengine.log_dir + "/#{check[:version]}/#{check[:protocol]}"
    check[:pid_file] = check[:pid_dir] + "/#{check[:basename]}.pid"
    check[:log_file] = check[:log_dir] + "/#{check[:basename]}.log"
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

  def root_dir; File.dirname(File.expand_path(File.dirname(__FILE__))) end
  def checks_dir; Cyberengine.root_dir + '/checks' end
  def log_dir; Cyberengine.root_dir + '/logs' end
  def pid_dir; Cyberengine.root_dir + "/pids" end
  def database_file; Cyberengine.root_dir + '/database.yml' end

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
    nil # Anything but nil means failure
  end


  def get_pid(check)
    pid_file = Cyberengine.check_pid_file(check)
    if File.exists?(pid_file) && File.readable?(pid_file)
      pid = File.read(pid_file).to_i
      begin
        Process.getpgid(pid) # PID in use? (raises Errno::ESRCH)
        return pid # Return non-nil value
      rescue Errno::ESRCH
      end
    end
    nil
  end
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
