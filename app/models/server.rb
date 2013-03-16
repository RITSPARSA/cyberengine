class Server < ActiveRecord::Base

  attr_accessible :name, :team_id

  belongs_to :team
  has_many :services, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy


  validates :name, presence: true, uniqueness: { scope: :team_id, message: "already taken" }
  validates :team, presence: { message: "must exist" }

  def self.ordered; order('name ASC') end

  # Standard permissions
  def self.can_new?(member,team_id) member.whiteteam? end 
  def can_show?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def can_edit?(member,team_id) member.whiteteam? end
  def can_create?(member,team_id) member.whiteteam? end
  def can_update?(member,team_id) member.whiteteam? end
  def can_destroy?(member,team_id) member.whiteteam? end
end
