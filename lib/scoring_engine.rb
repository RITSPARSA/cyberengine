require "scoring_engine/version"
require "scoring_engine/config"

require "scoring_engine/engine"
require "scoring_engine/logger"

require "scoring_engine/base_check"

require "scoring_engine/models/ability"
require "scoring_engine/models/check"
require "scoring_engine/models/member"
require "scoring_engine/models/property"
require "scoring_engine/models/server"
require "scoring_engine/models/service"
require "scoring_engine/models/team"
require "scoring_engine/models/user"

module ScoringEngine
  def self.root_dir; File.dirname(File.expand_path(File.dirname(__FILE__))) end
  def self.setup_dir; ScoringEngine.root_dir + '' end
  def self.checks_dir; ScoringEngine.root_dir + '/checks' end
  # def self.log_dir; ScoringEngine.root_dir + '/logs' end
  # def self.pid_dir; ScoringEngine.root_dir + "/pids" end
  def self.database_file; ScoringEngine.setup_dir + '/config/database.yml' end

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
