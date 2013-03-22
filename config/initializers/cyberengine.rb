module Cyberengine
  # Title/Brand 
  def self.title; 'ISTS' end
  def self.brand; 'ISTS' end

  # Overview page
  def self.can_show_all_blueteam_users; false end
  def self.can_show_all_blueteam_properties; false end

  # Scoreboard page
  def self.can_show_all_blueteam_scores; false end
end


module Blueteam
  # Allow username changes
  def self.can_update_usernames; false end 

  # Allow blueteams to view
  def self.can_show_all_blueteam_users; false end
  def self.can_show_all_blueteam_properties; false end

  # Scoreboard page
  def self.can_show_all_blueteam_scores; false end
end


module Redteam
  # Overview page
  def self.can_show_all_blueteam_users; false end
  def self.can_show_all_blueteam_properties; false end

  # Scoreboard page
  def self.can_show_all_blueteam_scores; false end
end
