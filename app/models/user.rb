class User < ActiveRecord::Base
  attr_accessible :password, :service_id, :username

  belongs_to :service

  validates :username, presence: true
  validates :password, presence: true
  validates :service, presence: { message: "must exist" }

end
