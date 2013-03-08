#!/usr/bin/env ruby
require_relative 'cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/logs/ping.log'
ce = Cyberengine.new(STDOUT,log)

@logger = ce.logger

def build_request(address,properties)
  # -n   = Do not resolve response IP to address
  # -c 1 = Wait for one successful response
  # -w 8 = Set timeout deadline to 8 seconds
  request = "ping -n -c 1 -w 8 #{address}"
  request
end

def execute_request(request)
  response = `#{request}`
  response
end

def parse_response(response)
  passed = true
  if response =~ /100% packet loss/ 
    passed = false
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
    @logger.error('ping') { log }  
  end
end

services = ce.get_services('Ping','ipv4','icmp')

services.each do |service|
  latest = service.checks.latest
  round = latest ? latest.round + 1 : 1
  properties = service.properties
  properties.addresses.each do |address|
    begin
      # Request command
      request = build_request(address,properties) 
      # Request output
      response = execute_request(request) 
      # Passed: true/false
      passed = parse_response(response) 
      # Save check and get result
      check = create_check(service,round,passed,request,response) 
      raise check.errors.full_messages.join(',') if check.errors.any?
    rescue Exception => exception
      exception_handler(service,exception)
    end
  end
end
