namespace :cyberengine do
  task :example => :environment do
    # Example Blueteam
    team = Team.create(color: 'Blue', name: 'Example Blueteam', alias: 'Example Blueteam' ) #'
    member = Member.create(team_id: team.id, username: 'test', password: 'test', password_confirmation: 'test')
    puts "Created: #{team.alias} - Login: #{member.username}:#{member.password}"

    server = Server.create(team_id: team.id, name: "Example Server")

    # DNS Forward
    service = Service.create(team_id: team.id, server_id: server.id, name: "DNS Forward", version: 'ipv4', protocol: 'dns', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'query-type', value: 'A')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'query', value: 'google-public-dns-a.google.com')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'google-public-dns-a.google.com', value: '8.8.8.8')

    # Echo Request
    service = Service.create(team_id: team.id, server_id: server.id, name: "Echo Request", version: 'ipv4', protocol: 'icmp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')

    # FTP Download
    service = Service.create(team_id: team.id, server_id: server.id, name: "FTP Download", version: 'ipv4', protocol: 'ftp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # FTP Upload
    service = Service.create(team_id: team.id, server_id: server.id, name: "FTP Upload", version: 'ipv4', protocol: 'ftp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # HTTP Available
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTP Available", version: 'ipv4', protocol: 'http', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')

    # HTTP Content
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTP Content", version: 'ipv4', protocol: 'http', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')

    # HTTPS Available
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTPS Available", version: 'ipv4', protocol: 'https', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')

    # HTTPS Content
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTPS Content", version: 'ipv4', protocol: 'https', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')

    # POP3 Login
    service = Service.create(team_id: team.id, server_id: server.id, name: "POP3 Login", version: 'ipv4', protocol: 'pop3', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # SMTP Send Mail
    service = Service.create(team_id: team.id, server_id: server.id, name: "SMTP Send Mail", version: 'ipv4', protocol: 'smtp', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'from-domain', value: 'cyberengine.ists')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'rcpt-domain', value: 'cyberengine.ists')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

    # SSH Login
    service = Service.create(team_id: team.id, server_id: server.id, name: "SSH Login", version: 'ipv4', protocol: 'ssh', enabled: true, available_points: 100)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'address', property: 'ip', value: '127.0.0.1')
    user = User.create(team_id: team.id, server_id: server.id, service_id: service.id, username: 'test', password: 'test')

  end
end