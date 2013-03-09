#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/ping.log'
@cyberengine = Cyberengine.new(STDOUT,log) 


def build_request(address,properties,users=[])
  # -n   = Do not resolve response IP to address
  # -c 1 = Wait for one successful response
  # -w 8 = Set timeout deadline to 8 seconds
  request = "ping -n -c 1 -w #{@cyberengine.timeout} #{address.shellescape}"
  request
end


def parse_response(response)
  passed = false
  if response =~ /\d+ bytes from / 
    passed = true
  end
  passed
end


services = @cyberengine.get_services('Ping','ipv4','icmp')
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
