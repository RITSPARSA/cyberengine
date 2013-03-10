#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/http-available.log'
@cyberengine = Cyberengine.new(STDOUT,log) 


def build_request(address,properties,users=[])
  # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
  # -S When used with -s it makes curl show an error message if it fails.
  # -4 Resolve names to IPv4 addresses only
  # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
  # -L Follow 302 redirects
  # -A Set request user-agent
  request = 'curl -s -S -4 -v '

  # Just incase
  address = address.shellescape
  
  # User-Agent
  request << " -A '#{@cyberengine.useragent}' "

  # URI
  uri = '' 
  unless properties.empty?
    property = properties.where('category = ? AND property = ?', 'random', 'uri').order('RANDOM()').first
    if property
      
  end

  request << " http://#{address}/#{uri} "

  request
end


# Determine if check passed 
def parse_response(response)
  passed = false
  if response =~ /> LIST/ 
    passed = true
  end
  passed
end


services = @cyberengine.get_services('POP3 Login','ipv4','pop3')
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
