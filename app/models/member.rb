class Member < ActiveRecord::Base
  #attr_accessible :password_digest, :team_id, :username 
  has_secure_password
  belongs_to :team

  attr_accessible :username, :team_id, :password, :password_confirmation

  validates :username, presence: true
  validates :username, uniqueness: { message: "already taken" }
  validates :password, presence: true
  validates :team, presence: { message: "must exist" }

end
