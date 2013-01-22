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
      team1_check1 = Check.create(team_id: team1.id, server_id: team1_server1.id, service_id: team1_service1.id, request: 'dig google.com', response: '; <<>> DiG 9.8.3-P2-RedHat-9.8.3-3.P2.fc16 <<>> google.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18665
;; flags: qr rd ra; QUERY: 1, ANSWER: 11, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;google.com.                    IN      A

;; ANSWER SECTION:
google.com.             299     IN      A       173.194.46.5
google.com.             299     IN      A       173.194.46.6
google.com.             299     IN      A       173.194.46.7
google.com.             299     IN      A       173.194.46.8
google.com.             299     IN      A       173.194.46.9
google.com.             299     IN      A       173.194.46.14
google.com.             299     IN      A       173.194.46.0
google.com.             299     IN      A       173.194.46.1
google.com.             299     IN      A       173.194.46.2
google.com.             299     IN      A       173.194.46.3
google.com.             299     IN      A       173.194.46.4

;; Query time: 57 msec
;; SERVER: 192.168.122.1#53(192.168.122.1)
;; WHEN: Sat Jan 19 22:53:52 2013
;; MSG SIZE  rcvd: 204

', passed: true)

    team1_service3 = Service.create(name: 'HTTP Server', team_id: team1.id, server_id: team1_server1.id, protocol: 'http', version: 'ipv4', enabled: true, points: 10)
    team1_service4 = Service.create(name: 'HTTPS Server', team_id: team1.id, server_id: team1_server1.id, protocol: 'https', version: 'ipv4', enabled: false, points: 10)

  team1_server2 = Server.create(name: 'Sauce', team_id: team1.id)
    team1_service2 = Service.create(name: 'Secondary DNS', team_id: team1.id, server_id: team1_server2.id, protocol: 'dns', version: 'ipv4', enabled: true, points: 10)
      team1_check2 = Check.create(team_id: team1.id, server_id: team1_server2.id, service_id: team1_service2.id, request: 'dig +short dns.team1.com', response: '10.0.1.10', passed: true)
      team1_check3 = Check.create(team_id: team1.id, server_id: team1_server2.id, service_id: team1_service2.id, request: 'dig dns.team1.com', response: ';; connection timed out; no servers could be reached', passed: false)

  team1_server3 = Server.create(name: 'Empty', team_id: team1.id)


team2 = Team.create(color: 'blue', name: 'DropTables', alias: 'Team2' )
  team2_member = Member.create(username: 'team2', team_id: team2.id, password: 'team2', password_confirmation: 'team2')
