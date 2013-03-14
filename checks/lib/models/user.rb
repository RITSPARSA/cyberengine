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

  private
  def self.random
    user = self.order('RANDOM()').first
    user ? user : nil
  end

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


end
