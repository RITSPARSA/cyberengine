#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/ftp-upload.log'


@cyberengine = Cyberengine.new(STDOUT,log) 
@logger = @cyberengine.logger


def build_request(address,properties,users=[])
  # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
  # -S When used with -s it makes curl show an error message if it fails.
  # -4 Resolve names to IPv4 addresses only
  # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
  # -u Provide username and password colon seperated. user:password
  # -T Upload file or STDIN if '-' is used 
  # --ftp-pasv Force FTP passive mode (server opens high port for upload connection)
  # --ftp-create-dirs Attempt creation of missing directories in upload (normally fails)
  request = 'curl -s -S -4 -v --ftp-pasv --ftp-create-dirs '

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
 
  # Upload gets text from STDIN
  request.prepend("echo 'cyberengine check' | ")
  request << ' -T - '

  # FTP filename
  filename = @cyberengine.filename

  # FTP URL   
  request << " ftp://#{username}:#{password}@#{address}/#{filename} "
  puts request

  request
end


def execute_request(request)
  response = `#{request} 2>&1`
  response
end


def parse_response(response)
  passed = false
  if response =~ /226 Transfer complete/ 
    passed = true
  end
  passed
end


def create_check(service,round,passed,request,response)
  check = Hash.new
  check[:team_id] = service.team_id
  check[:server_id] = service.server_id
  check[:service_id] = service.id
  check[:round] = round
  check[:passed] = passed
  check[:request] = request
  check[:response] = response
  Check.create(check)
end


def exception_handler(service,exception)
  team = service.team.alias
  service = service.name
  logs = Array.new
  logs << "Exception raised during check - Team: #{team} - Service: #{service}"
  logs << "Exception message: #{exception.message}"
  logs << "Exception backtrace: #{exception.backtrace}"
  logs.each do |log|
    @logger.error { log }  
  end
end


services = @cyberengine.get_services('FTP Upload','ipv4','ftp')
services.each do |service|
  round = service.checks.next_round
  properties = service.properties
  users = service.users
  properties.addresses.each do |address|
    # Mark start of check in log
    @logger.info { "Starting check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name} - Address: #{address}" }

    begin
      # Request command
      request = build_request(address,properties,users) 

      # Request output
      response = execute_request(request) 

      # Passed: true/false
      passed = parse_response(response) 

      # Save check and get result
      check = create_check(service,round,passed,request,response) 

      # Check for errors in saving check 
      raise check.errors.full_messages.join(',') if check.errors.any?

      # Mark end of check in log
      result = passed ? 'Passed' : 'Failed'
      @logger.info { "Completed check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name} - Address: #{address} - Result: #{result}" }

    rescue Exception => exception
      exception_handler(service,exception)
    end
  end
end
