require 'resque/tasks'

require 'scoring_engine/engine'

task "resque:setup" => :environment
