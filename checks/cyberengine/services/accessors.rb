class Cyberengine
def get_services(name, version, protocol)
  # Get services
  services = Service.where('name = ? AND version = ? AND protocol = ? AND enabled = ?', name, version, protocol, true)

  # Convert from ActiveRecord::Relation to Array
  services = services.map{|s| s }

  # Return services
  services
end
end
