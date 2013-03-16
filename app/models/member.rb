class Member < ActiveRecord::Base
  has_secure_password

  attr_accessible :team_id, :username, :password, :password_confirmation

  belongs_to :team

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true
  validates :team, presence: { message: "must exist" }

  def logged_in?; !id.nil?  end
  def whiteteam?; team.whiteteam? end
  def blueteam?; team.blueteam? end
  def redteam?; team.redteam? end

  # Standard permissions
  def self.can_index?(member) member.whiteteam? end
  def can_show?(member) member.whiteteam? end
  def self.can_new?(member) member.whiteteam? end 
  def can_edit?(member) member.whiteteam? end
  def can_create?(member) member.whiteteam? end
  def can_update?(member) member.whiteteam? end
  def can_destroy?(member) member.whiteteam? end
  def can_overview_users?
    return true if Cyberengine.can_show_all_blueteam_users
    return true if Blueteam.can_show_all_blueteam_users 
    return true if Redteam.can_show_all_blueteam_users
    false
  end
  def can_overview_properties?
    return true if Cyberengine.can_show_all_blueteam_properties
    return true if Blueteam.can_show_all_blueteam_properties && blueteam?
    return true if Redteam.can_show_all_blueteam_properties && redteam?
    false
  end
  def can_scoreboard?
    return true if Cyberengine.can_show_all_blueteam_scores
    return true if Blueteam.can_show_all_blueteam_scores && blueteam?
    return true if Redteam.can_show_all_blueteam_scores && redteam? 
    false
  end

end
