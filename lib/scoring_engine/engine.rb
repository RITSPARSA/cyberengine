require 'active_record'
require 'resque'

require_relative 'models'

require_relative 'engine/machine'
require_relative 'engine/exceptions'
require_relative 'engine/work_unit'

module ScoringEngine
  module Engine
    def self.create_check(service,round,passed,request,response)
      check = Hash.new
      check[:team_id] = service.team_id
      check[:server_id] = service.server_id
      check[:service_id] = service.id
      check[:round] = round
      check[:passed] = passed
      check[:request] = request
      check[:response] = response
      check = Check.create(check)
      check
    end
  end
end

rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'

redis_config = YAML.load_file(rails_root + '/config/redis.yml')
Resque.redis = redis_config[rails_env]