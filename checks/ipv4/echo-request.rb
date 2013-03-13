#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/echo-request.log'
@cyberengine = Cyberengine.new(STDOUT,log) 


@services = @cyberengine.services('Echo Request','ipv4','icmp')
@defaults = @cyberengine.defaults('Echo Request','ipv4','icmp')


def build_request(service,address)
  # -n   = Do not resolve response IP to address
  # -c 1 = Wait for one successful response
  # -w 8 = Set timeout deadline to 8 seconds
  request = "ping -n -c 1 "

  # Timeout
  timeout = service.properties.option('timeout') || @defaults.properties.option('timeout')
  raise("Missing timeout property") unless timeout
  timeout = timeout.to_f
  request << " -w #{timeout} "

  # Each line regex match
  @each_line_regex = service.properties.answer('each-line-regex') || @defaults.properties.answer('each-line-regex')
  @full_text_regex = service.properties.answer('full-text-regex') || @defaults.properties.answer('full-text-regex')
  raise "Missing answer property: each-line-regex or full-text-regex required" unless @each_line_regex || @full_text_regex

  # URL 
  request << " #{address}"

  # Return request single spaced and without leading/ending spaces
  request.strip.squeeze(' ')
end


# Determine if check passed 
def parse_response(response)
  passed = false
  if @each_line_regex
    begin @each_line_regex = Regexp.new(@each_line_regex) rescue raise("Invalid each-line-regex: #{@each_line_regex}") end
    response.each_line do |line|
      passed = true if line =~ @each_line_regex
    end
  end
  if @full_text_regex
    begin @full_text_regex = Regexp.new(@full_text_regex) rescue raise("Invalid full-text-regex: #{@each_line_regex}") end
    passed = true if response =~ @full_text_regex
  end
  passed
end


@services.each do |service|
  service.properties.addresses.each do |address|
    # Mark start of check in log
    @cyberengine.logger.info { "Starting check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name} - Address: #{address}" }

    begin
      # Request command
      request = build_request(service,address) 

      # Get request output
      response = @cyberengine.shellcommand(request,service,@defaults)

      # Passed: true/false
      passed = parse_response(response) 

      # Save check and get result
      round = service.checks.next_round
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
