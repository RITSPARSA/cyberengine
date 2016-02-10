namespace :scoringengine do
  task :example => :environment do
    # Example Blueteam
    team = Team.create(color: 'Blue', name: 'Example Blueteam', alias: 'Example Blueteam' ) #'
    member = Member.create(team_id: team.id, username: 'test', password: 'test', password_confirmation: 'test')
    puts "Created: #{team.alias} - Login: #{member.username}:#{member.password}"

    server = Server.create(team_id: team.id, name: "Example Server")

    # DNS Domain Query
    service = Service.create(team_id: team.id, server_id: server.id, name: "DNS Domain Query", version: 'ipv4', protocol: 'dns', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'query-type', value: 'A')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'query', value: 'google-public-dns-a.google.com')

    # ICMP Ping
    service = Service.create(team_id: team.id, server_id: server.id, name: "ICMP Ping", version: 'ipv4', protocol: 'icmp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')

    # IRC Channel Join
    # service = Service.create(team_id: team.id, server_id: server.id, name: "IRC Channel Join", version: 'ipv4', protocol: 'irc', enabled: true, available_points: 100)
    # property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'domain', value: 'irc.freenode.org')
    # user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # FTP Download
    service = Service.create(team_id: team.id, server_id: server.id, name: "FTP Download", version: 'ipv4', protocol: 'ftp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # FTP Upload
    service = Service.create(team_id: team.id, server_id: server.id, name: "FTP Upload", version: 'ipv4', protocol: 'ftp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # FTPS Download
    # service = Service.create(team_id: team.id, server_id: server.id, name: "FTPS Download", version: 'ipv4', protocol: 'ftps', enabled: true, available_points: 100)
    # property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    # user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # FTPS Upload
    # service = Service.create(team_id: team.id, server_id: server.id, name: "FTPS Upload", version: 'ipv4', protocol: 'ftps', enabled: true, available_points: 100)
    # property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    # user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # HTTP Available
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTP Available", version: 'ipv4', protocol: 'http', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')

    # HTTP Content
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTP Content", version: 'ipv4', protocol: 'http', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')

    # HTTPS Available
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTPS Available", version: 'ipv4', protocol: 'https', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')

    # HTTPS Content
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTPS Content", version: 'ipv4', protocol: 'https', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')

    # POP3 Login
    service = Service.create(team_id: team.id, server_id: server.id, name: "POP3 Login", version: 'ipv4', protocol: 'pop3', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # SMTP Send Mail
    service = Service.create(team_id: team.id, server_id: server.id, name: "SMTP Send Mail", version: 'ipv4', protocol: 'smtp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'from-domain', value: 'engine.ists')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'rcpt-domain', value: 'engine.ists')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # SMTPS Send Mail
    # service = Service.create(team_id: team.id, server_id: server.id, name: "SMTPS Send Mail", version: 'ipv4', protocol: 'smtps', enabled: true, available_points: 100)
    # property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    # property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'from-domain', value: 'engine.ists')
    # property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'rcpt-domain', value: 'engine.ists')
    # user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # SSH Login
    service = Service.create(team_id: team.id, server_id: server.id, name: "SSH Login", version: 'ipv4', protocol: 'ssh', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

  end
end
