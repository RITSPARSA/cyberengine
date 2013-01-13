class Member < ActiveRecord::Base
  has_secure_password

  attr_accessible :username, :team_id, :password, :password_confirmation

  belongs_to :team

  validates :username, presence: true, uniqueness: { scope: :team_id, message: "already taken" }
  validates :password, presence: true
  validates :team, presence: { message: "must exist" }

  def whiteteam?
    self if self.team && self.team.color == 'white'
  end
  def blueteam?
    self if self.team && self.team.color == 'blue'
  end
  def redteam?
    self if self.team && self.team.color == 'red'
  end
end
