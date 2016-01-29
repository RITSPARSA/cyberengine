class Property < ActiveRecord::Base

  attr_accessible :team_id, :server_id, :service_id, :category, :value, :property, :visible

  belongs_to :team
  belongs_to :server
  belongs_to :service

  validates :category, presence: true
  validates :property, presence: true
  validates :value, presence: true
  validates :team, presence: { message: "must exist" }
  validates :server, presence: { message: "must exist" }
  validates :service, presence: { message: "must exist" }
  validate :right_team?


  def self.ordered; order('team_id ASC, server_id ASC, service_id ASC, category ASC, property ASC') end

  # Mostly used in check scripts
  def self.addresses; self.select(:value).where('category = ?', 'address').map{|p| p.value} end
  def self.random(property) (where('category = ? AND property = ?', 'random', property).order('RANDOM()').first || Property.new).value end
  def self.randoms(property) where('category = ? AND property = ?', 'random', property).order('RANDOM()') end
  def self.option(property) (where('category = ? AND property = ?', 'option', property).first || Property.new).value end
  def self.options(property) where('category = ? AND property = ?', 'option', property) end
  def self.answer(property) (where('category = ? AND property = ?', 'answer', property).first || Property.new).value end
  def self.answers(property) where('category = ? AND property = ?', 'answer', property) end
  def self.temp(property) (where('category = ? AND property = ?', 'temp', property).first || Property.new).value end
  def self.temps(property) where('category = ? AND property = ?', 'temp', property) end
  def self.visible; self.where('visible = ?',true) end

  def right_team?
    team = Team.find_by_id(team_id)
    server = Server.find_by_id(server_id)
    service = Service.find_by_id(service_id)
    unless team && server && service && team.id == server.team_id && team.id == service.team_id && team.id == team_id
      errors.add_to_base("Server, Service, and Property must belong to same Team")
    end
    unless team && server && service && server.id == service.server_id && server.id == server_id
      errors.add_to_base("Service and Property must belong to same Server")
    end
  end

  # Standard permissions
  def can_show?(member,team_id) member.whiteteam? || visible || member.team_id == team_id end
  def self.can_show?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def self.can_new?(member,team_id) member.whiteteam? end 
  def can_edit?(member,team_id) member.whiteteam? end
  def can_create?(member,team_id) member.whiteteam? end
  def can_update?(member,team_id) member.whiteteam? end
  def can_destroy?(member,team_id) member.whiteteam? end
end
