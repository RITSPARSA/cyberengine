#!/usr/bin/env ruby
require_relative '../cyberengine/cyberengine'
log = File.dirname(__FILE__) + '/../logs/ipv4/dns-forward.log'
@cyberengine = Cyberengine.new(STDOUT,log) 


@services = @cyberengine.services('DNS Forward','ipv4','dns')
@defaults = @cyberengine.defaults('DNS Forward','ipv4','dns')


def build_request(service,address)
  # @<address> = DNS server address
  # -t = type of request - PTR, A, or AAAA
  # -q = domain to perform query for
  request = "dig @#{address} "

  # query-type
  query_type = service.properties.option('query-type')
  raise("Missing query-type property") unless query_type

  # query
  query = service.properties.random('query') 
  raise("Missing query property") unless query

  # answer
  @answer = service.properties.answer(query) 
  raise "Missing answer property for query '#{query}'" unless @answer

  # Build request
  request << " -t #{query_type} -q #{query} "

  # Return request single spaced and without leading/ending spaces
  request.strip.squeeze(' ')
end


# Determine if check passed (compare all returned answers to real answer)
def parse_response(response)
  passed = false
  answers = response.scan(/;; ANSWER SECTION:\s(.*?);;/m)
  return passed if answers.empty? # No answers or no server response
  answers.join("\n").each_line do |line|
    answer = line.split(/[\t\n]+/).last.to_s.strip
    passed = true if @answer == answer
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
