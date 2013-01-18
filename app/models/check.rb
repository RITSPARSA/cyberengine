class Check < ActiveRecord::Base
  attr_accessible :passed, :request, :response, :service_id

  belongs_to :service

  validates :request, presence: true
  validates :response, presence: true
  validates :service, presence: { message: "must exist" }

  def self.latest
    first(order: 'created_at DESC')
  end
end
