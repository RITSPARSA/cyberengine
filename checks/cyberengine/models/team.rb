class Team < ActiveRecord::Base

  before_validation :downcase_color
  before_validation :capitalize_name

  attr_accessible :color, :name, :alias

  has_many :members, dependent: :destroy
  has_many :servers, dependent: :destroy
  has_many :services, dependent: :destroy
  has_many :properties, dependent: :destroy
  has_many :checks, dependent: :destroy
  has_many :users, dependent: :destroy


  validates :name, presence: true
  validates :alias, presence: true
  validates :color, presence: true, inclusion: { in: ['white','red','blue'] }


  def self.blueteams
    where(color: "blue")
  end

  def self.rounds
    puts Check.select('round').uniq.map{|c| c.round}.size
  end


  private
  def downcase_color
    self.color = self.color.downcase if self.color.present?
  end

  def capitalize_name
    self.name = self.name.downcase.capitalize if self.name.present?
  end

end
