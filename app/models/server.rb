class Server < ActiveRecord::Base

  attr_accessible :name, :team_id

  belongs_to :team

  validates :name, presence: true, uniqueness: { scope: :team_id, message: "already taken" }
  validates :team, presence: { message: "must exist" }

end
