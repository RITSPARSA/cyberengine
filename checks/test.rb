class PrettyFormatter 
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

  def call(severity, time, progname, msg)
    # Log options at end
    options = Hash.new

    # Remove colors
    msg.gsub!(/\e\[.{0,4}m/,'')

    # Remove ending/leading spaces
    msg.strip!
 
    # Beautify SQL logs
    if msg =~ /(SELECT|INSERT|UPDATE|DELETE|COUNT|JOIN)/
      pretty_sql = pretty_sql(msg)
      msg = pretty_sql.delete(:sql)
      options.merge!(pretty_sql)
    end

    # Beautify severity
    pretty_severity = pretty_severity(severity)
    severity = pretty_severity.delete(:severity)
    options.merge!(pretty_severity)

    # PID
    options[:pid] = start_color(:yellow) + "#{$$}" + clear_color

    # Time
    time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
    
    # Options to string
    options = options.map{|k,v| "#{k}:" + v }.join(' ')

    # Return pretty log
    "#{time} #{severity}  #{msg}  [#{options}]\n"
  end

  def pretty_severity(severity)
    # To match severity_to_color_map
    severity.upcase!
  
    # Map used to colorize severity - Green: 32, Red: 31, Yellow: 32, Normal: 37
    severity_to_color_map = {'DEBUG'=>:white, 'INFO'=>:green, 'WARN'=>:yellow, 'ERROR'=>:red, 'FATAL'=>:red }

    # Get color
    color = severity_to_color_map[severity] 

    # Format severity
    severity = "[" + severity + "]"

    # For right justify
    size = severity.length

    # Colorize severity
    severity.gsub!(/\A\[/, '[' + start_color(color))
    severity.gsub!(/\]\z/, clear_color + ']')

    # Format with spaces before string 
    # sprintf unreliable because of invisible color characters
    0..(7-size).times do 
      severity.prepend(' ')
    end

    # Return pretty severity
    { severity: severity }
  end

  def pretty_sql(sql)
    # Get model if available
    sql_model = /\A(?<model>[\w\s]+) Load\s+/
    match = sql.match(sql_model) || { model: 'Unknown' }
    sql.gsub!(sql_model,'')
    model = match[:model]

    # Get loadtime if available
    sql_loadtime = /\A\((?<loadtime>[^)]+)\)\s+/
    match = sql.match(sql_loadtime) || { loadtime: '0.0' }
    sql.gsub!(sql_loadtime,'')
    loadtime = match[:loadtime]

    # Replace variables in SQL statement
    match = sql.match(/\[(\["?\w+"?, "?\w+"?\])+\]\z/)
    sql.gsub!(/\[(\["?\w+"?, "?\w+"?\])+\]\z/,'')
    if match
      count = 1
      match.captures.each do |m|
        last = m.match(/, "?(?<last>\w+)"?\]/)[:last]
        sql.gsub!("$#{count}",last)
        count += 1
      end
    end

    # Colorize SQL commands
    sql.gsub!(/[A-Z]{2,}/) {|m| start_color(:green) + m.to_s + clear_color }

    # Colorize model
    model = start_color(:green) + model + clear_color

    # Colorize loadtime
    loadtime = start_color(:yellow) + loadtime + clear_color

    # Return captures
    { sql: sql, model: model, loadtime: loadtime }
  end
end


class MultiIO
  def initialize(*targets)
     @targets = Array.new
     targets.each do |target|
       @targets << to_io(target)
     end
  end

  def to_io(target)
    if target.is_a?(String)
      return File.open(target, 'a')
    elsif target.is_a?(IO) || target.is_a?(File)
      return target
    end
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

#logger = ActiveRecord::Base.logger = Logger.new(MultiLogger.new(STDOUT,'file.log'))

require 'active_record'
require 'active_support'
require 'logger'
logger = Logger.new(MultiIO.new(STDOUT,'file.log'))
logger.formatter = PrettyFormatter.new
ActiveRecord::Base.logger = logger

class Team < ActiveRecord::Base; end
@connection = ActiveRecord::Base.establish_connection({"adapter"=>"postgresql", "encoding"=>"unicode", "database"=>"cyberengine_development", "pool"=>5, "username"=>"cyberengine", "password"=>"cyberengine"})
Team.where('id = ?',3).first
