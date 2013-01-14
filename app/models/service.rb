class Service < ActiveRecord::Base

  before_validation :downcase_protocol
  before_validation :downcase_version

  attr_accessible :enabled, :protocol, :server_id, :version, :name

  belongs_to :server
  has_many :properties

  validates :name, presence: true, uniqueness: { scope: :server_id, message: "already taken" }
  validates :version, presence: true, inclusion: { in: ['ipv4','ipv6'] }
  validates :protocol, presence: true
  validates :server, presence: { message: "must exist" }

  private

  def downcase_protocol
    self.protocol = self.protocol.downcase if self.protocol.present?
  end

  def downcase_version
    self.version = self.version.downcase if self.version.present?
  end

end
