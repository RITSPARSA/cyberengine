class Team < ActiveRecord::Base

  before_validation :capitalize_color

  attr_accessible :color, :name, :alias

  has_many :members, dependent: :destroy
  has_many :servers, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy


  validates :name, presence: true, uniqueness: true
  validates :alias, presence: true, uniqueness: true
  validates :color, presence: true, inclusion: { in: ['White','Red','Blue'] }


  def self.blueteams
    where(color: 'Blue')
  end

  def self.rounds
    puts Check.select('round').uniq.map{|c| c.round}.size
  end


  private
  def capitalize_color
    self.color = self.color.capitalize if self.color.present?
  end

end
