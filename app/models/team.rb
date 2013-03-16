class Team < ActiveRecord::Base

  before_validation :capitalize_color

  attr_accessible :color, :name, :alias

  has_many :members, dependent: :destroy
  has_many :servers, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :checks_for_scoring, class_name: Check, select: "checks.team_id,checks.id,checks.service_id,checks.passed"


  validates :name, presence: true, uniqueness: true
  validates :alias, presence: true, uniqueness: true
  validates :color, presence: true, inclusion: { in: ['White','Red','Blue'] }


  def whiteteam?; color == 'White' end
  def blueteam?; color == 'Blue' end
  def redteam?; color == 'Red' end
  def self.blueteams; where(color: 'Blue') end
  #def self.services; order("version,protocol DESC") end

  def capitalize_color
    self.color = self.color.capitalize if self.color.present?
  end

  def self.ordered; order('color DESC,alias ASC'); end
  # Standard permissions
  def can_index?(member,team_id) color == 'Blue' || member.whiteteam? || member.team.color == color end
  def can_show?(member,team_id) member.whiteteam? || member.team_id == team_id end
  def self.can_new?(member) member.whiteteam? end 
  def can_edit?(member,team_id) member.whiteteam? end
  def can_create?(member,team_id) member.whiteteam? end
  def can_update?(member,team_id) member.whiteteam? end
  def can_destroy?(member,team_id) member.whiteteam? end

end
