class Member < ActiveRecord::Base
  has_secure_password

  attr_accessible :team_id, :username, :password, :password_confirmation

  belongs_to :team

  validates :username, presence: true, uniqueness: { scope: :team_id, message: "already taken for Team" }
  validates :password, presence: true
  validates :team, presence: { message: "must exist" }
end
