class Service < ActiveRecord::Base

  before_validation :downcase_protocol
  before_validation :downcase_version

  attr_accessible :team_id, :server_id, :enabled, :protocol, :version, :name, :available_points

  belongs_to :team
  belongs_to :server

  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :name, presence: true #, uniqueness: { scope: :server_id, message: "already taken" }
  validates :version, presence: true, inclusion: { in: ['ipv4','ipv6'] }
  validates :protocol, presence: true
  validates :available_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :team, presence: { message: "must exist" }
  validates :server, presence: { message: "must exist" }
  validate :right_team?


  def scoring
    checks = self.checks.all
    scoring = Hash.new
    scoring[:service] = self
    scoring[:count] = checks.size
    scoring[:passed] = checks.map{|c| c if c.passed }.compact.size
    scoring[:available] = self.available_points
    scoring[:percent] = scoring[:count] == 0 ? 0 : scoring[:passed].to_f/scoring[:count].to_f 
    scoring[:percent_rounded] = (scoring[:percent] * 100).round(1)
    scoring[:points] = scoring[:available] * scoring[:percent]
    scoring[:points_rounded] = scoring[:points].round(1)
    scoring
  end


  private
  def self.scoring
    services = all.map{|s| s.scoring }
    scoring = Hash.new
    scoring[:services] = services
    scoring[:count] = services.map{|s| s[:count] }.sum
    scoring[:passed] = services.map{|s| s[:passed] }.sum
    scoring[:available] = services.map{|s| s[:available] }.sum
    scoring[:percent] = services.map{|s| s[:percent] }.sum / services.size
    scoring[:percent_rounded] = (scoring[:percent] * 100).round(1)
    scoring[:points] = services.map{|s| s[:points] }.sum
    scoring[:points_rounded] = scoring[:points].round(1)
    scoring
  end

  def self.checks
    services = self.select('id').uniq.map{|s| s.id }
    Check.select('round,passed,service_id').where(service_id: services) 
  end

  def self.points
    services = self.select('id').uniq.map{|s| s.checks.points }
  end

  def self.available_points
    services = self.select('available_points').map{|s| s.available_points }
  end

  def self.versions
    select(:version).uniq
  end

  def self.protocols
    select(:protocol).uniq
  end


  def right_team?
    team = Team.find_by_id(team_id)
    server = Server.find_by_id(server_id)
    unless team && server && team.id == server.team_id && team.id == team_id
      errors.add_to_base("Server and Service must belong to same Team")
    end
  end

  def downcase_protocol
    self.protocol = self.protocol.downcase if self.protocol.present?
  end

  def downcase_version
    self.version = self.version.downcase if self.version.present?
  end

end
