require 'active_record'

require_relative 'models'

require_relative 'engine/machine'
require_relative 'engine/exceptions'

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