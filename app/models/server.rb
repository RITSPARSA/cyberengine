class Server < ActiveRecord::Base
  before_validation :capitalize_name

  attr_accessible :name, :team_id

  belongs_to :team
  has_many :services, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy


  validates :name, presence: true, uniqueness: { scope: :team_id, message: "already taken" }
  validates :team, presence: { message: "must exist" }


  private 
  def capitalize_name
    self.name = self.name.downcase.capitalize if self.name.present?
  end

end
