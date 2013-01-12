class Team < ActiveRecord::Base
  before_validation :downcase_color
  before_validation :capitalize_name
  attr_accessible :color, :name, :alias
  validates :name, presence: true
  validates :alias, presence: true
  validates :color, presence: true
  validates :color, :inclusion => { :in => ['white','red','blue','black','gold'] }


  private
  def downcase_color
    self.color = self.color.downcase if self.color.present?
  end
  def capitalize_name
    self.name = self.name.downcase.capitalize if self.name.present?
  end
end
