class StaticController < ApplicationController
  def welcome
  end

  def scoreboard
    @teams = Team.blueteams.ordered
    @bargraph = Array.new
    @colors = ['#FF1493','#F08080','#DC143C','#FF4500','#FF0000','#FFD700','#008000','#32CD32','#40E0D0','#4169E1','#9370DB']
    @teams.each do |team|
      points = team.services.scoring[:points_rounded]
      color = @colors[team.id % @colors.size]
      @bargraph << { y: points, color: "#{color}" }
    end
    #FF1493 MediumViolet
    #F08080 LightCoral
    #DC143C Crimson
    #FF4500 OrangeRed
    #FFD700 Gold
    #32CD32 LimeGreen
    #00FA9A MediumGreen
    #008000 Green
    #40E0D0 Turquoise
    #4169E1 RoyalBlue
    #9370DB Medium Purple
  end
end
