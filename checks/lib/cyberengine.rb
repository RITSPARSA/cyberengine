require_relative 'checker'
require_relative 'database'
require_relative 'logging/logging'

module Cyberengine
  def root(file=nil)
    File.expand_path(File.dirname(file)) if file # Base directory unless file 
    File.dirname(File.expand_path(File.dirname(__FILE__))) # Files root
  end

  def checks_dir
    Cyberengine.root + "/checks"
  end

  def checkify(file,args,options={})
    check = Hash.new
    check[:name] = Cyberengine.basename(file)
    check[:path] = Cyberengine.path(file)
    check[:test] = true if args.include?('test')
    check[:daemon] = true if args.include?('daemon')
    check[:delay] = options[:delay].to_i <= 5 ? 5 : options[:delay].to_i 
    check
  end

  def check_delay(check)
    check[:delay]
  end
  def check_name(check)
    check[:name] 
  end
  def check_path(check)
    check[:path] 
  end
  def check_test(check)
    check[:test] 
  end
  def check_daemon(check)
    check[:daemon] 
  end

  def defaults(name, version, protocol)
    Service.where('team_id = ? AND name = ? AND version = ? AND protocol = ? AND enabled = ?', @whiteteam.id, name, version, protocol, false).first
  end

  def log_dir(check=nil)
    return File.dirname(Cyberengine.log_file(check)) if check
    Cyberengine.root + "/logs"
  end

  def pid_dir(check=nil)
    return File.dirname(Cyberengine.pid_file(check)) if check
    Cyberengine.root + "/pids"
  end

  def log_file(check)
    path = Cyberengine.check_path(check)
    name = Cyberengine.check_name(check)
    Cyberengine.root + "/logs/#{path}/#{name}.log"
  end

  def pid_file(check)
    path = Cyberengine.check_path(check)
    name = Cyberengine.check_name(check)
    Cyberengine.root + "/pids/#{path}/#{name}.pid"
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

  # Detach and become daemon
  def daemonize(check)
    return get_pid(check) if get_pid(check)
    Process.daemon
    File.open(pid_file(check),'w') {|file| file.write(Process.pid) }
    nil # Return nil, anything else means error
  end

  # Return only filename without extensions
  def basename(file)
    File.basename(file).split('.').first.to_s
  end

  def get_pid(check)
    pid_file = Cyberengine.pid_file(check)
    if File.exists?(pid_file) && File.readable?(pid_file)
      pid = File.read(pid_file).to_i
      begin
        Process.getpgid(pid)
        return pid
      rescue Errno::ESRCH
      end
    end
    nil
  end

  # Return only filename's path 
  def path(file)
    File.basename(File.expand_path(File.dirname(file)))
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
