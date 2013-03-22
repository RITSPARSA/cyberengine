class User < ActiveRecord::Base
  attr_accessible :team_id, :server_id, :service_id, :username, :password

  belongs_to :team
  belongs_to :server
  belongs_to :service

  validates :username, presence: true
  validates :password, presence: true
  validates :team, presence: { message: "must exist" }
  validates :server, presence: { message: "must exist" }
  validates :service, presence: { message: "must exist" }
  validate :right_team?

  def self.to_csv; all.map{|u| "#{u.username},#{u.password}"}.join("\r\n") end
  def self.random; order('RANDOM()').first || nil end
  def self.ordered; order('team_id ASC, server_id ASC, service_id ASC, username ASC') end

  def right_team?
    team = Team.find_by_id(team_id)
    server = Server.find_by_id(server_id)
    service = Service.find_by_id(service_id)
    unless team && server && service && team.id == server.team_id && team.id == service.team_id && team.id == team_id
      errors.add_to_base("Server, Service, and User must belong to same Team")
    end
    unless team && server && service && server.id == service.server_id && server.id == server_id
      errors.add_to_base("Service and User must belong to same Server")
    end
  end

  # Standard permissions
  def can_show?(member,team_id) member.whiteteam? || service.can_show?(member,team_id) && member.team_id == team_id end
  def self.can_show?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def self.can_new?(member,team_id) member.whiteteam? end
  def can_edit?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def self.can_edit?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def can_create?(member,team_id) member.whiteteam? end
  def can_update?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def can_destroy?(member,team_id) member.whiteteam? end

end
