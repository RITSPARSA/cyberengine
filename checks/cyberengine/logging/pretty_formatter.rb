class PrettyFormatter 
  def call(severity, time, progname, msg)
    # Log options at end
    options = Hash.new

    # Remove bold colors
    msg.gsub!(/\e\[.{0,4}m/,'')

    # Remove ending/leading spaces
    msg.strip!

    # Remove multiple spaces
    msg.gsub!(/\s+/,' ')
 
    # Beautify SQL logs
    if msg =~ /(SELECT|INSERT|UPDATE|DELETE|COUNT|JOIN)/
      pretty_sql = pretty_sql(msg)
      msg = pretty_sql.delete(:sql)
      options.merge!(pretty_sql)
    end

    # Get loadtime
    if msg =~ /\(\d+\.\d+ms\)/
      loadtime = loadtime(msg)
      msg = loadtime.delete(:msg)
      options.merge!(loadtime)
    end

    # Remove ending/leading spaces
    msg.strip!

    # Beautify severity
    pretty_severity = pretty_severity(severity)
    severity = pretty_severity.delete(:severity)
    options.merge!(pretty_severity)

    # PID - unused currently
    # options[:pid] = start_color(:yellow) + $$.to_s + clear_color

    # Time
    time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
    
    # Options to string
    options = options.map{|k,v| "#{k}:" + v }.join(', ')

    # Return pretty log
    return "#{time} #{severity} - #{msg}  [#{options}]\n" unless options.empty?
    "#{time} #{severity} - #{msg}\n"
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
    # Remove any current colors
    sql.gsub!(/\e\[.{0,4}m/,'')

    # Get model if available
    model_regex = /\A(?<model>[\w\s]+) Load\s+/
    match = sql.match(model_regex) || { model: nil }
    model = match[:model]
    sql.gsub!(model_regex,'') if model

    # Colorize SQL commands
    sql.gsub!(/[A-Z]{2,}/) {|m| start_color(:green) + m.to_s + clear_color } if sql

    # Colorize model
    model = start_color(:green) + model + clear_color if model

    # Return captures
    captures = Hash.new
    captures[:sql] = sql if sql
    #captures[:model] = model if model
    captures
  end


  def loadtime(msg)
    # Get loadtime if available
    loadtime_regex = /\s?\((?<loadtime>\d+\.\d+ms)\)/
    match = msg.match(loadtime_regex) || { loadtime: nil }
    loadtime = match[:loadtime]
    msg.gsub!(loadtime_regex,'') if loadtime

    # Colorize loadtime
    loadtime = start_color(:yellow) + loadtime + clear_color if loadtime

    # Return captures
    captures = Hash.new
    captures[:msg] = msg if msg
    captures[:time] = loadtime if loadtime
    captures
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
end
