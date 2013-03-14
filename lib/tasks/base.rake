namespace :cyberengine do
  task :base => :environment do
    # Whiteteam
    team = Team.create(color: 'White', name: 'Whiteteam', alias: 'Whiteteam' )
    member = Member.create(team_id: team.id, username: 'whiteteam', password: 'whiteteam', password_confirmation: 'whiteteam')
    puts "Created: #{team.alias} - Login: #{member.username}:#{member.password}"

    server = Server.create(team_id: team.id, name: "Defaults")

    # DNS Forward
    service = Service.create(team_id: team.id, server_id: server.id, name: "DNS Forward", version: 'ipv4', protocol: 'dns', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')

    # Echo Request
    service = Service.create(team_id: team.id, server_id: server.id, name: "Echo Request", version: 'ipv4', protocol: 'icmp', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '\d+ bytes from')

    # FTP Download
    service = Service.create(team_id: team.id, server_id: server.id, name: "FTP Download", version: 'ipv4', protocol: 'ftp', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'filename', value: '/cyberengine')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '^< 226')

    # FTP Upload
    service = Service.create(team_id: team.id, server_id: server.id, name: "FTP Upload", version: 'ipv4', protocol: 'ftp', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'filename', value: '/cyberengine')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '^< 226')

    # HTTP Available
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTP Available", version: 'ipv4', protocol: 'http', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')
    useragents.each do |useragent|
      property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'useragent', value: useragent)
    end
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '^< (Status: 200|HTTP\/1.(1|0) 200 OK)')

    # HTTP Content
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTP Content", version: 'ipv4', protocol: 'http', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')
    useragents.each do |useragent|
      property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'useragent', value: useragent)
    end
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '<title>.*</title>')

    # HTTPS Available
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTPS Available", version: 'ipv4', protocol: 'https', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')
    useragents.each do |useragent|
      property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'useragent', value: useragent)
    end
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '^< (Status: 200|HTTP\/1.(1|0) 200 OK)')

    # HTTPS Content
    service = Service.create(team_id: team.id, server_id: server.id, name: "HTTPS Content", version: 'ipv4', protocol: 'https', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'uri', value: '/')
    useragents.each do |useragent|
      property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'useragent', value: useragent)
    end
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '<title>.*</title>')

    # POP3 Login
    service = Service.create(team_id: team.id, server_id: server.id, name: "POP3 Login", version: 'ipv4', protocol: 'pop3', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '^> LIST')

    # SMTP Send Mail
    service = Service.create(team_id: team.id, server_id: server.id, name: "SMTP Send Mail", version: 'ipv4', protocol: 'smtp', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'full-text-regex', value: 'data not shown\]\s*< 250')

    # SSH Login
    service = Service.create(team_id: team.id, server_id: server.id, name: "SSH Login", version: 'ipv4', protocol: 'ssh', enabled: false, available_points: 0)
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'option', property: 'timeout', value: '30.0')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'random', property: 'command', value: 'echo "cyberengine check"')
    property = Property.create(team_id: team.id, server_id: server.id, service_id: service.id, visible: true, category: 'answer', property: 'each-line-regex', value: '^cyberengine check$')

    # Redteam
    team = Team.create(color: 'Red', name: 'Redteam', alias: 'Redteam' )
    member = Member.create(team_id: team.id, username: 'redteam', password: 'redteam', password_confirmation: 'redteam')
    puts "Created: #{team.alias} - Login: #{member.username}:#{member.password}"
  end

  def useragents
    [
      'Baiduspider+(+http://www.baidu.com/search/spider.htm)',
      'curl/7.18.2 (i686-pc-linux-gnu) libcurl/7.18.2 GnuTLS/2.3.11 zlib/1.2.3',
      'ia_archiver (+http://www.alexa.com/site/help/webmasters; crawler@alexa.com)',
      'Mediapartners-Google',
      'Mozilla/4.0 (compatible; MSIE 6.0; MSIE 5.5; Windows NT 5.0) Opera 7.02 Bork-edition [en]',
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1;)',
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1)',
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; FunWebProducts; .NET CLR 1.1.4322; PeoplePal 6.2)',
      'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; MRA 5.8 (build 4157); .NET CLR 2.0.50727; AskTbPTV/5.11.3.15590)',
      'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; SV1; .NET CLR 2.0.50727)',
      'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322)',
      'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)',
      'Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; Trident/4.0; Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1) ; .NET CLR 3.5.30729)',
      'Mozilla/4.0 (compatible; Netcraft Web Server Survey)',
      'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
      'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)',
      'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)',
      'Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)',
      'Mozilla/5.0 (iPad; CPU OS 6_1 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B141 Safari/8536.25',
      'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3 (compatible; Googlebot-Mobile/2.1; +http://www.google.com/bot.html)',
      'Mozilla/5.0 (Linux; U; Android 2.2; fr-fr; Desire_A8181 Build/FRF91) App3leWebKit/53.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.57.2 (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.17 (KHTML, like Gecko) Version/6.0.2 Safari/536.26.17',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.152 Safari/537.22',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.99 Safari/537.22',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:18.0) Gecko/20100101 Firefox/18.0',
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10.8; rv:19.0) Gecko/20100101 Firefox/19.0',
      'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Windows NT 5.1) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22',
      'Mozilla/5.0 (Windows NT 5.1; rv:11.0) Gecko/20100101 Firefox/11.0',
      'Mozilla/5.0 (Windows NT 5.1; rv:13.0) Gecko/20100101 Firefox/13.0.1',
      'Mozilla/5.0 (Windows NT 5.1; rv:18.0) Gecko/20100101 Firefox/18.0',
      'Mozilla/5.0 (Windows NT 5.1; rv:19.0) Gecko/20100101 Firefox/19.0',
      'Mozilla/5.0 (Windows NT 5.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1',
      'Mozilla/5.0 (Windows NT 5.1; rv:5.0.1) Gecko/20100101 Firefox/5.0.1',
      'Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1',
      'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22',
      'Mozilla/5.0 (Windows NT 6.1; rv:18.0) Gecko/20100101 Firefox/18.0',
      'Mozilla/5.0 (Windows NT 6.1; rv:19.0) Gecko/20100101 Firefox/19.0',
      'Mozilla/5.0 (Windows NT 6.1; rv:2.0b7pre) Gecko/20100921 Firefox/4.0b7pre',
      'Mozilla/5.0 (Windows NT 6.1; rv:5.0) Gecko/20100101 Firefox/5.02',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/13.0.782.112 Safari/535.1',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.152 Safari/537.22',
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22',
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:18.0) Gecko/20100101 Firefox/18.0',
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:19.0) Gecko/20100101 Firefox/19.0',
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/5.0',
      'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.57 Safari/537.17',
      'Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.97 Safari/537.22',
      'Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.2) Gecko/20100115 Firefox/3.6',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/535.1 (KHTML, like Gecko) Chrome/14.0.835.109 Safari/535.1',
      'msnbot-webmaster/1.0 (+http://search.msn.com/msnbot.htm)',
      'Opera/9.80 (Windows NT 5.1; U; en) Presto/2.10.289 Version/12.01',
      'Wget/1.10.2',
      'YandexSomething/1.0'
    ]
  end
end
