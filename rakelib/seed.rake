namespace :scoringengine do
  task :seed => :environment do
    teams = Array(1..10)
    teams = teams.map{|t| t+Team.all.size}
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
    puts "\nTeam member login: team1:team1, team2:team2, etc..."
    size = Team.all.size
    for team in teams do
      print "#{team-size}";
      print "," unless team == teams.last
      name = "team#{team-size}"
      Team.create(color: 'blue', name: name, alias: name)
      Member.create(team_id: team, username: name, password: name, password_confirmation: name)
    end

    puts "\n\nPopulating #{servers.size} random servers"
    for server in servers do
      print "#{server}"
      print "," unless server == servers.last
      team = teams.sample
      Server.create(team_id: team, name: "Server#{server}")
    end

    puts "\n\nPopulating #{services.size} random services"
    for service in services do
      print "#{service}"
      print "," unless service == services.last
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
      print "," unless property == properties.last
      team = teams.sample
      server = Team.find(team).servers.map {|s| s.id }.sample
      next unless server
      service = Server.find(server).services.map {|s| s.id }.sample
      next unless service
      Property.create(team_id: team, server_id: server, service_id: service, category: random, property: random, value: random, visible: boolean.sample)
    end

    puts "\n\nPopulating random #{users.size} users"
    for user in users do
      print "#{user}"
      print "," unless user == users.last
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
      print "," unless round == rounds.last
      log = "line1 line1 line1 line1 line1 line1 line1 line1 line1\n line2 line2 line2 line2 line2 line2 line2 line2 line2"
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
  end
end
