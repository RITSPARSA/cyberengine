unless Rails.env.production?
  class ActiveSupport::BufferedLogger
    def formatter=(formatter)
      @log.formatter = formatter
    end
  end

  class Formatter
    SEVERITY_TO_COLOR_MAP   = {'DEBUG'=>'0;37', 'INFO'=>'32', 'WARN'=>'33', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}

    def call(severity, time, progname, msg)
      
      pid = "\033[0;33m(pid:#{$$})\033[0m"
      if msg.strip == '' || (/\/assets\//).match(msg)
        nil
      elsif (/Started\s/).match(msg)
        formatted_time = time.strftime("%Y-%m-%d %H:%M:%S.") << time.usec.to_s[0..2].rjust(3)
        "\n\033[0;34m#{msg.strip} \033[0m #{pid}\n"
      else
        formatted_severity = sprintf("%-5s","#{severity}")
        severity = "\033[#{SEVERITY_TO_COLOR_MAP[severity]}m#{formatted_severity}\033[0m"
        " [#{severity}] #{msg.strip} #{pid}\n"
      end
      
    end

  end

  Rails.logger.formatter = Formatter.new
end
