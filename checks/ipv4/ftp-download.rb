#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/ftp-download.log'
@cyberengine = Cyberengine.new(STDOUT,log) 


def build_request(address,properties,users=[])
  # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
  # -S When used with -s it makes curl show an error message if it fails.
  # -4 Resolve names to IPv4 addresses only
  # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
  # --ftp-pasv Force FTP passive mode (server opens high port for upload connection)
  request = 'curl -s -S -4 -v --ftp-pasv '

  # Just incase
  address = address.shellescape

  # User
  username = 'anonymous'
  password = 'anonymous'
  unless users.empty?
    user = users.random
    username = user.username.url_encode
    password = user.password.url_encode
  end

  # Default
  filename = 'cyberengine'
  unless properties.empty?
    property = properties.where('category = ? AND property = ?', 'option', 'filepath').first
    if property
      filename = property.value.url_encode
    end
  end
 
  # FTP URL   
  request << " ftp://#{username}:#{password}@#{address}/#{filename} "

  request
end


# Determine if check passed 
def parse_response(response)
  passed = false
  if response =~ /226 Transfer complete/ 
    passed = true
  end
  passed
end


services = @cyberengine.get_services('FTP Download','ipv4','ftp')
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
