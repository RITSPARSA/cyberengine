module Cyberengine
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
end
