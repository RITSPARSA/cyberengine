class Service < ActiveRecord::Base

  before_validation :downcase_protocol
  before_validation :downcase_version
  before_validation :capitalize_name

  attr_accessible :team_id, :server_id, :enabled, :protocol, :version, :name, :points_per_check

  belongs_to :team
  belongs_to :server

  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :server_id, message: "already taken" }
  validates :version, presence: true, inclusion: { in: ['ipv4','ipv6'] }
  validates :protocol, presence: true
  validates :points_per_check, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :team, presence: { message: "must exist" }
  validates :server, presence: { message: "must exist" }
  validate :right_team?


  private
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

  def downcase_version
    self.version = self.version.downcase if self.version.present?
  end

  def capitalize_name
    self.name = self.name.downcase.capitalize if self.name.present?
  end


end
