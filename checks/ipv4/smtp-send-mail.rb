#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/smtp-send-mail.log'
@cyberengine = Cyberengine.new(STDOUT,log) 


def build_request(address,properties,users=[])
  # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
  # -S When used with -s it makes curl show an error message if it fails.
  # -4 Resolve names to IPv4 addresses only
  # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
  # --mail-from Source mail address user@domain
  # --mail-rcpt Destination mail address user@domain
  request = 'curl -s -S -4 -v '
  puts "'".url_encode
  # Just incase
  address = address.shellescape

  # From/Rcpt defaults
  username = 'anonymous'
  password = 'anonymous'
  from_domain = 'cyberengine.ists'
  rcpt_user = 'whiteteam'
  rcpt_domain = 'cyberengine.ists'
  unless users.empty?
    user = users.random
    username = user.username.url_encode
    password = user.password.url_encode
    rcpt_user = users.random.username.url_encode
    unless properties.empty?
      # From domain
      property = properties.where('category = ? AND property = ?','from','domain').first
      from_domain = property.value.url_encode if property
      
      # Rcpt user/domain
      property = properties.where('category = ? AND property = ?','rcpt','domain').first
      rcpt_domain = property.value if property
      property = properties.where('category = ? AND property = ?','rcpt','user').first
      rcpt_user = property.value.url_encode if property
    end
  end

  # Add from/rcpt 
  request << " --mail-from '#{username}'@'#{from_domain}' --mail-rcpt '#{rcpt_user}'@'#{rcpt_domain}' " 

  # Mail gets text from STDIN
  request.prepend("echo 'cyberengine check' | ")
  request << ' -T - '

  request << " smtp://#{username}:#{password}@#{address}"

  request
end


# Determine if check passed 
def parse_response(response)
  passed = false
  if response =~ /data not shown\]\s*< 250/ 
    passed = true
  end
  passed
end


services = @cyberengine.get_services('SMTP Send Mail','ipv4','smtp')
services.each do |service|
  round = service.checks.next_round
  properties = service.properties
  users = service.users
  properties.addresses.each do |address|
    # Mark start of check in log
    @cyberengine.logger.info { "Starting check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name} - Address: #{address}" }

    begin
      # Request command
      request = build_request(address,properties,users) 

      # Get request output
      response = @cyberengine.shellcommand(request) 

      # Passed: true/false
      passed = parse_response(response) 

      # Save check and get result
      check = @cyberengine.create_check(service,round,passed,request,response) 

      # Check for errors in saving check 
      raise check.errors.full_messages.join(',') if check.errors.any?

      # Mark end of check in log
      result = passed ? 'Passed' : 'Failed'
      @cyberengine.logger.info { "Finished check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name} - Address: #{address} - Result: #{result}" }

    rescue Exception => exception
      @cyberengine.exception_handler(service,exception)
    end
  end
end
