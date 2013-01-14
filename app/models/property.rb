class Property < ActiveRecord::Base

  attr_accessible :property, :service_id, :category, :value

  belongs_to :service

  validates :category, presence: true
  validates :property, presence: true
  validates :value, presence: true
  validates :service, presence: { message: "must exist" }

end
