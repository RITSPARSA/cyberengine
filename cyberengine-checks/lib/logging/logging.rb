module Cyberengine
  class Logging
    require 'logger'
    require_relative 'multi_io'
    require_relative 'pretty_formatter'
    
    attr_accessor :logger
    def initialize(check)
      log_file = Cyberengine.check_log_file(check)
      #daemon = Cyberengine.check_daemon(check)
      #multiio = daemon ? Cyberengine::MultiIO.new(log_file) : Cyberengine::MultiIO.new(STDOUT,log_file)
      multiio = Cyberengine::MultiIO.new(STDOUT,log_file)
      @logger = Logger.new(multiio)
      @logger.formatter = Cyberengine::PrettyFormatter.new
    end

    def daemonize
      $stdout.reopen("/dev/null", "w")
      $stderr.reopen("/dev/null", "w")
    end
  end
end
