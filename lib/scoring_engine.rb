require "scoring_engine/version"

require "scoring_engine/engine"
require "scoring_engine/logger"

require "scoring_engine/engine/base_check"

module ScoringEngine
  def self.root_dir; File.dirname(File.expand_path(File.dirname(__FILE__))) end
  def self.setup_dir; ScoringEngine.root_dir + '' end
  def self.checks_dir; ScoringEngine.root_dir + '/checks' end
  # def self.log_dir; ScoringEngine.root_dir + '/logs' end
  # def self.pid_dir; ScoringEngine.root_dir + "/pids" end
  def self.database_file; ScoringEngine.setup_dir + '/config/database.yml' end
end
