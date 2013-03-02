# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

# Whiteteam
whiteteam = Team.create(color: 'white', name: 'Whiteteam', alias: 'Whiteteam' )
whiteteam_member = Member.create(username: 'whiteteam', team_id: whiteteam.id, password: 'whiteteam', password_confirmation: 'whiteteam')

# Redteam
redteam = Team.create(color: 'red', name: 'Redteam', alias: 'Redteam' )
redteam_member = Member.create(username: 'redteam', team_id: redteam.id, password: 'redteam', password_confirmation: 'redteam')

teams = Array(1..10)
servers = Array(1..50)
services = Array(1..100)
properties = Array(1..400)
users = Array(1..400)
rounds = Array(1..400)

protocols = ['dns','ftp','http','https','smtp','pop3','ssh']
versions = ['ipv4','ipv6']
boolean = [true,false]
available_points = [250]

def random
  (0...10).map{(65+rand(26)).chr}.join
end

puts "\nPopulating #{teams.size} random teams"
for team in teams do 
  print "#{team}"; 
  print "," unless team == teams.size
  name = "team#{team}"
  Team.create(color: 'blue', name: name, alias: name)
  Member.create(team_id: team+2, username: name, password: name, password_confirmation: name)
end
teams = teams.map{|t| t+2}

puts "\n\nPopulating #{servers.size} random servers"
for server in servers do
  print "#{server}"
  print "," unless server == servers.size
  team = teams.sample
  Server.create(team_id: team, name: "Server#{server}")
end

puts "\n\nPopulating #{services.size} random services"
for service in services do
  print "#{service}"
  print "," unless service == services.size
  team = teams.sample
  server = Team.find(team).servers.map {|s| s.id }.sample
  next unless server
  protocol = protocols.sample
  version = versions.sample
  enabled = boolean.sample
  Service.create(team_id: team, name: "Service#{service}", server_id: server, protocol: protocol, version: version, enabled: enabled, available_points: available_points.sample)
end

puts "\n\nPopulating random #{properties.size} properties"
for property in properties do
  print "#{property}"
  print "," unless property == properties.size
  team = teams.sample
  server = Team.find(team).servers.map {|s| s.id }.sample
  next unless server
  service = Server.find(server).services.map {|s| s.id }.sample
  next unless service
  Property.create(team_id: team, server_id: server, service_id: service, category: random, property: random, value: random)
end

puts "\n\nPopulating random #{users.size} users"
for user in users do
  print "#{user}"
  print "," unless user == users.size
  team = teams.sample
  server = Team.find(team).servers.map {|s| s.id }.sample
  next unless server
  service = Server.find(server).services.map {|s| s.id }.sample
  next unless service
  User.create(team_id: team, server_id: server, service_id: service, username: random, password: random)
end

puts "\n\nPopulating #{rounds.size} random check rounds"
for round in rounds do
  print "#{round}"
  print "," unless round == rounds.size
  log = 'line1 line1 line1 line1 line1 line1 line1 line1 line1\n line2 line2 line2 line2 line2 line2 line2 line2 line2'
  teams.sample(rand(1..teams.length)).each do |team|
    server = Team.find(team).servers.map {|s| s.id }.sample
    next unless server
    service = Server.find(server).services.map {|s| s.id }.sample
    next unless service
    Check.create(team_id: team, server_id: server, service_id: service, request: 'random seed data', response: log, passed: boolean.sample, round: round )
    Check.create(team_id: team, server_id: server, service_id: service, request: 'random seed data', response: log, passed: boolean.sample, round: round )
    Check.create(team_id: team, server_id: server, service_id: service, request: 'random seed data', response: log, passed: boolean.sample, round: round )
  end
end
puts "\n\nCompleted population of seed data"
