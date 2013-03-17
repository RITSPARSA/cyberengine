class Service < ActiveRecord::Base

  before_validation :downcase_protocol
  before_validation :downcase_version

  attr_accessible :team_id, :server_id, :enabled, :protocol, :version, :name, :available_points

  belongs_to :team
  belongs_to :server

  has_many :users, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :checks_for_scoring, class_name: Check, select: 'service_id,passed'

  validates :name, presence: true
  validates :version, presence: true, inclusion: { in: ['ipv4','ipv6'] }
  validates :protocol, presence: true
  validates :available_points, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :team, presence: { message: "must exist" }
  validates :server, presence: { message: "must exist" }
  validate :right_team?

  def self.ordered; order('version ASC, protocol ASC, name DESC') end

  def right_team?
    team = Team.find_by_id(team_id)
    server = Server.find_by_id(server_id)
    unless team && server && team.id == server.team_id && team.id == team_id
      errors.add_to_base("Server and Service must belong to same Team")
    end
  end

  def downcase_protocol; self.protocol = self.protocol.downcase if self.protocol.present? end
  def downcase_version; self.version = self.version.downcase if self.version.present? end

  # Standard permissions
  def can_show?(member,team_id) member.whiteteam? || enabled && member.team_id == team_id end
  def self.can_new?(member,team_id) member.whiteteam? end 
  def can_edit?(member,team_id) member.whiteteam? end
  def can_create?(member,team_id) member.whiteteam? end
  def can_update?(member,team_id) member.whiteteam? end
  def can_destroy?(member,team_id) member.whiteteam? end

  # Custom permissions
  def can_overview?(member,team_id) member.whiteteam? || enabled end
end
