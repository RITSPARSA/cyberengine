module Cyberengine
  class Logging
    require 'logger'
    require_relative 'multi_io'
    require_relative 'pretty_formatter'
    
    attr_accessor :logger
    def initialize(check)
      # Set options
      path = Cyberengine.check_path(check)
      name = Cyberengine.check_name(check)
      daemon = Cyberengine.check_daemon(check)
      log = Cyberengine.log_file(check)
      multiio = daemon ? Cyberengine::MultiIO.new(log) : Cyberengine::MultiIO.new(STDOUT,log)
      @logger = Logger.new(multiio)
      @logger.formatter = Cyberengine::PrettyFormatter.new
    end
  end
end
