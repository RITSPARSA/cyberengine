#!/usr/bin/env ruby
require_relative '../../../lib/cyberengine'
@check = Cyberengine.checkify(__FILE__,ARGV.dup)
@cyberengine = Cyberengine::Checker.new(@check)
@cyberengine.signals


def build_request(service,address)
  # -s Silent or quiet mode. Dont show progress meter or error messages.  Makes Curl mute.
  # -S When used with -s it makes curl show an error message if it fails.
  # -4 Resolve names to IPv4 addresses only
  # -v Verbose mode. '>' means sent data. '<' means received data. '*' means additional info provided by curl
  # -L Follow 302 redirects
  # -A Set request user-agent
  # -k Ignore certificate errors
  # --ssl-reqd Force SSL user
  request = 'curl -s -S -4 -v -L -k --ssl-reqd '

  # Useragent
  useragent = service.properties.random('useragent') || @cyberengine.defaults.properties.random('useragent')
  useragent.gsub!("'",'') if useragent
  request << " -A '#{useragent}' " if useragent

  # URI
  uri = service.properties.random('uri') || @cyberengine.defaults.properties.random('uri')
  raise("Missing uri property") unless uri

  # Each line regex match
  @each_line_regex = service.properties.answer('each-line-regex') || @cyberengine.defaults.properties.answer('each-line-regex')
  @full_text_regex = service.properties.answer('full-text-regex') || @cyberengine.defaults.properties.answer('full-text-regex')
  raise "Missing answer property: each-line-regex or full-text-regex required" unless @each_line_regex || @full_text_regex
 
  request << " http://#{address}#{uri} "

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


# Loop until terminated (TERM Signal)
until @cyberengine.stop
  begin
    @cyberengine.services.each do |service|
      service.properties.addresses.each do |address|
        # Mark start of check in log
        @cyberengine.logger.info { "Starting check - Team: #{service.team.alias} - Server: #{service.server.name} - Service: #{service.name} - Address: #{address}" }
    
        begin
          # Request command
          request = build_request(service,address) 
    
          # Get request output
          response = @cyberengine.shellcommand(request,service)

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

        rescue StandardError => exception
          @cyberengine.exception_handler(service,exception)
        end
      end
    end
    unless @cyberengine.stop
      @cyberengine.logger.info { "Sleeping for #{@cyberengine.delay} seconds between rounds" }
      sleep @cyberengine.delay
    end
  rescue StandardError => exception
    @cyberengine.fatal_exception_handler(exception)
  end
end
@cyberengine.terminate
