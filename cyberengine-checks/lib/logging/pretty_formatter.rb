module Cyberengine
  class PrettyFormatter
    attr_accessor :sql
    def initialize()
      @sql = /(ADD|EXCEPT|PERCENT|ALL|EXEC|PLAN|ALTER|EXECUTE|PRECISION|AND|EXISTS|PRIMARY|ANY|EXIT|PRINT|AS|FETCH|PROC|ASC|FILE|PROCEDURE|AUTHORIZATION|FILLFACTOR|PUBLIC|BACKUP|FOR|RAISERROR|BEGIN|FOREIGN|READ|BETWEEN|FREETEXT|READTEXT|BREAK|FREETEXTTABLE|RECONFIGURE|BROWSE|FROM|REFERENCES|BULK|FULL|REPLICATION|BY|FUNCTION|RESTORE|CASCADE|GOTO|RESTRICT|CASE|GRANT|RETURN|CHECK|GROUP|REVOKE|CHECKPOINT|HAVING|RIGHT|CLOSE|HOLDLOCK|ROLLBACK|CLUSTERED|IDENTITY|ROWCOUNT|COALESCE|IDENTITY|INSERT|ROWGUIDCOL|COLLATE|IDENTITYCOL|RULE|COLUMN|IF|SAVE|COMMIT|IN|SCHEMA|COMPUTE|INDEX|SELECT|CONSTRAINT|INNER|SESSION|USER|CONTAINS|INSERT|SET|CONTAINSTABLE|INTERSECT|SETUSER|CONTINUE|INTO|SHUTDOWN|CONVERT|IS|SOME|CREATE|JOIN|STATISTICS|CROSS|KEY|SYSTEM|USER|CURRENT|KILL|TABLE|CURRENT|DATE|LEFT|TEXTSIZE|CURRENT|TIME|LIKE|THEN|CURRENT|TIMESTAMP|LINENO|TO|CURRENT|USER|LOAD|TOP|CURSOR|NATIONAL|TRAN|DATABASE|NOCHECK|TRANSACTION|DBCC|NONCLUSTERED|TRIGGER|DEALLOCATE|NOT|TRUNCATE|DECLARE|NULL|TSEQUAL|DEFAULT|NULLIF|UNION|DELETE|OF|UNIQUE|DENY|OFF|UPDATE|DESC|OFFSETS|UPDATETEXT|DISK|ON|USE|DISTINCT|OPEN|USER|DISTRIBUTED|OPENDATASOURCE|VALUES|DOUBLE|OPENQUERY|VARYING|DROP|OPENROWSET|VIEW|DUMMY|OPENXML|WAITFOR|DUMP|OPTION|WHEN|ELSE|OR|WHERE|END|ORDER|WHILE|ERRLVL|OUTER|WITH|ESCAPE|OVER|WRITETEXT|RETURNING|SQL|LIMIT|shown|CR)/
    end
  
    def call(severity, time, progname, msg)
      # Log options at end
      options = Hash.new
  
      # Remove bold and colors
      msg.gsub!(/\e\[.{0,4}m/,'')

      # Remove ending/leading spaces
      msg.strip!
  
      # Beautify SQL logs
      if msg =~ @sql
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
      size = Process.pid.size
      pid = Process.pid.to_s
      #pid = Cyberengine.start_color(:yellow) + Process.pid.to_s + Cyberengine.clear_color
      #pid.prepend("pid:")
      
      # Time
      time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
      
      # Options to string
      options = options.map{|k,v| "#{k}:" + v }.join(', ')
  
      # Return pretty log
      result = options.empty? ? "#{time} #{severity} - #{pid} - #{msg}\n" : "#{time} #{severity} - #{pid} - #{msg}  [#{options}]\n"
      puts result
      result
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
      #severity.gsub!(/\A\[/, '[' + Cyberengine.start_color(color))
      #severity.gsub!(/\]\z/, Cyberengine.clear_color + ']')
  
      # Format with spaces before string 
      # sprintf unreliable because of invisible color characters
      0..(7-size).times do 
        severity.prepend(' ')
      end
  
      # Return pretty severity
      { severity: severity }
    end
  
  
  
    def pretty_sql(sql)
      # Remove bold and colors
      sql.gsub!(/\e\[.{0,4}m/,'')
  
      # Get model if available
      model_regex = /\A(?<model>[\w\s]+) Load\s+/
      match = sql.match(model_regex) || { model: nil }
      model = match[:model]
      sql.gsub!(model_regex,'') if model
  
      # Colorize SQL commands
      #sql_queries = sql.split(/\[\[.*\]\]/)
      #sql_queries.each do |query| 
      #  colored = query.split(/\s+/).map do |word|
      #    word =~ /\A#{@sql}\z/ ? Cyberengine.start_color(:green) + word.to_s + Cyberengine.clear_color : word
      #  end.join(' ')
      #  sql.gsub!(query,colored)
      #end
  
      # Colorize model
      #model = Cyberengine.start_color(:green) + model + Cyberengine.clear_color if model
  
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
      # loadtime = Cyberengine.start_color(:yellow) + loadtime + Cyberengine.clear_color if loadtime
  
      # Return captures
      captures = Hash.new
      captures[:msg] = msg if msg
      captures[:time] = loadtime if loadtime
      captures
    end
   
  end
end
