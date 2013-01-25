# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Whiteteam
whiteteam = Team.create(color: 'white', name: 'Whiteteam', alias: 'Whiteteam' )
whiteteam_member = Member.create(username: 'whiteteam', team_id: whiteteam.id, password: 'whiteteam', password_confirmation: 'whiteteam')

# Redteam
redteam = Team.create(color: 'red', name: 'Redteam', alias: 'Redteam' )
redteam_member = Member.create(username: 'redteam', team_id: redteam.id, password: 'redteam', password_confirmation: 'redteam')

# Blueteams
## Team 1
team1 = Team.create(color: 'blue', name: 'AwesomeSauce', alias: 'Team1' )
  team1_member = Member.create(username: 'team1', team_id: team1.id, password: 'team1', password_confirmation: 'team1')

  team1_server1 = Server.create(name: 'Awesome', team_id: team1.id)
    team1_service1 = Service.create(name: 'Primary DNS', team_id: team1.id, server_id: team1_server1.id, protocol: 'dns', version: 'ipv4', enabled: true, points: 10)
      team1_property1 = Property.create(team_id: team1.id, server_id: team1_server1.id, service_id: team1_service1.id, category: 'address', property: 'ip', value: '10.0.1.10')
      team1_property2 = Property.create(team_id: team1.id, server_id: team1_server1.id, service_id: team1_service1.id, category: 'dns', property: 'forward', value: 'dns.team1.com')
      team1_property2 = Property.create(team_id: team1.id, server_id: team1_server1.id, service_id: team1_service1.id, category: 'dns', property: 'reverse', value: '10.1.0.10.in-addr.arpa')
      team1_user1 = User.create(team_id: team1.id, server_id: team1_server1.id, service_id: team1_service1.id, username: 'user1', password: 'user1')
      team1_user1 = User.create(team_id: team1.id, server_id: team1_server1.id, service_id: team1_service1.id, username: 'user2', password: 'user2')
    team1_service3 = Service.create(name: 'HTTP Server', team_id: team1.id, server_id: team1_server1.id, protocol: 'http', version: 'ipv4', enabled: true, points: 10)
    team1_service4 = Service.create(name: 'HTTPS Server', team_id: team1.id, server_id: team1_server1.id, protocol: 'https', version: 'ipv4', enabled: false, points: 10)

  team1_server2 = Server.create(name: 'Sauce', team_id: team1.id)
    team1_service2 = Service.create(name: 'Secondary DNS', team_id: team1.id, server_id: team1_server2.id, protocol: 'dns', version: 'ipv4', enabled: true, points: 10)
      team1_check2 = Check.create(team_id: team1.id, server_id: team1_server2.id, service_id: team1_service2.id, request: 'dig +short dns.team1.com', response: '10.0.1.10', passed: true)
      team1_check3 = Check.create(team_id: team1.id, server_id: team1_server2.id, service_id: team1_service2.id, request: 'dig dns.team1.com', response: ';; connection timed out; no servers could be reached <script>alert("XSS")</script>', passed: false)

  team1_server3 = Server.create(name: 'Empty', team_id: team1.id)


team2 = Team.create(color: 'blue', name: 'DropTables', alias: 'Team2' )
  team2_member = Member.create(username: 'team2', team_id: team2.id, password: 'team2', password_confirmation: 'team2')
  team2_server1 = Server.create(name: 'ExampleServer', team_id: team2.id)
    team2_service1 = Service.create(name: 'Primary DNS', team_id: team2.id, server_id: team2_server1.id, protocol: 'dns', version: 'ipv4', enabled: true, points: 10)
      team2_property1 = Property.create(team_id: team2.id, server_id: team2_server1.id, service_id: team2_service1.id, category: 'address', property: 'ip', value: '10.0.1.10')
      team2_property2 = Property.create(team_id: team2.id, server_id: team2_server1.id, service_id: team2_service1.id, category: 'dns', property: 'forward', value: 'dns.team2.com')
      team2_property2 = Property.create(team_id: team2.id, server_id: team2_server1.id, service_id: team2_service1.id, category: 'dns', property: 'reverse', value: '10.1.0.10.in-addr.arpa')
      team2_user1 = User.create(team_id: team2.id, server_id: team2_server1.id, service_id: team2_service1.id, username: 'user1', password: 'user1')
      team2_user1 = User.create(team_id: team2.id, server_id: team2_server1.id, service_id: team2_service1.id, username: 'user2', password: 'user2')

puts "Populating random checks with db/seeds.log..."
check = ""
File.readlines("#{File.dirname(__FILE__)}/seeds.log").each do |line|
  check += line
  service = rand(1..3)
  if rand(1..10) != 1
    next
  else
    rand(1..2) == 1 ? passed = true : passed = false
    Check.create(team_id: team1.id, server_id: team1_server1.id, service_id: service, request: 'random seed data', response: check, passed: passed )
    check = ""
  end
end

