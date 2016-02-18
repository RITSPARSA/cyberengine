class StaticController < ApplicationController
  def welcome
  end

  def scoreboard
    @teams = Array.new
    @bargraph = Array.new
    @scoreboard = Hash.new
    @colors = ['#FF1493','#F08080','#DC143C','#FF4500','#FF0000','#FFD700','#008000','#32CD32','#40E0D0','#4169E1','#9370DB']
    Team.blueteams.includes([services_for_scoring: :checks_for_scoring]).each do |team|
      @scoreboard[team.id] = {checks: 0, passed: 0, percent: 0.0, points: 0, available: 0, alias: team.alias, team: team, services: Hash.new}
      team.services_for_scoring.each do |service|
        @scoreboard[team.id][:services][service.id] = {checks: 0, passed: 0, percent: 0.0, points: 0, available: service.available_points, name: service.name, protocol: service.protocol, version: service.version, service: service}
        service.checks_for_scoring.each do |check|
          @scoreboard[team.id][:checks] += 1
          @scoreboard[team.id][:passed] += 1 if check.passed
          @scoreboard[team.id][:services][service.id][:checks] += 1
          @scoreboard[team.id][:services][service.id][:passed] += 1 if check.passed
        end
      end
    end
    # Calculate percent, available, and points
    @scoreboard.each do |team_id,team|
      team[:percent] = team[:checks] == 0 ? 0 : (team[:passed].to_f/team[:checks].to_f)
      team[:available] = team[:services].map{|i,s| s[:available] }.sum.to_i
      team[:percent] = (team[:percent]*100).round(1)

      total_points = 0
      team[:services].each do |service_id,service|
        service[:percent] = service[:checks] == 0 ? 0 : (service[:passed].to_f/service[:checks].to_f)
        service[:available] = service[:available].to_i
        service[:points] = (service[:available]*service[:percent]).to_i
        total_points += service[:points]
        service[:percent] = (service[:percent]*100).round(1)
      end
      team[:points] = total_points
      @bargraph << { y: team[:points], color: @colors[team_id % @colors.size] }
      @teams << team[:alias]
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
