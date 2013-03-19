#!/usr/bin/env ruby
require_relative '../../../lib/cyberengine'
@check = Cyberengine.checkify(__FILE__,ARGV.dup)
@cyberengine = Cyberengine::Checker.new(@check)
@cyberengine.signals
require 'net/ssh'


def build_request(service,address)
  request = Hash.new
  request[:address] = address

  # User
  user = service.users.random
  raise "Missing users" unless user
  request[:username] = user.username
  request[:password] = user.password

  # Command
  command = service.properties.random('command') || @cyberengine.defaults.properties.random('command')
  raise("Missing command property") unless command
  command.gsub!('$USER',request[:username])
  request[:command] = command

  # Each line regex match
  @each_line_regex = service.properties.answer('each-line-regex') || @cyberengine.defaults.properties.answer('each-line-regex')
  @full_text_regex = service.properties.answer('full-text-regex') || @cyberengine.defaults.properties.answer('full-text-regex')
  raise "Missing answer property: each-line-regex or full-text-regex required" unless @each_line_regex || @full_text_regex

  # Return request hash
  request
end


def execute_request(request,service,defaults)
  response = ''
  command = request[:command]
  username = request[:username]
  password = request[:password]
  address = request[:address]
  timeout = service.properties.option('timeout') || defaults.properties.option('timeout')
  raise("Missing timeout property") unless timeout
  timeout = timeout.to_f
  @cyberengine.logger.debug { "Timeout: #{timeout}" }
  request.each do |key,value|
    @cyberengine.logger.debug { "#{key.capitalize}: #{value}" }
  end

  begin
    Timeout::timeout(timeout) do
      Net::SSH.start(address, username, password: password) do |ssh|
        ssh.exec!(command) do |channel, stream, data|
          response << data
        end
      end
    end
  rescue Timeout::Error => exception
    response << "Check exceeded #{timeout} second timeout"
  rescue StandardError => exception
    message = exception.message.empty? ? 'None' : exception.message
    raise "SSH command exection exception - Type: #{exception.class} - Message: #{message} - Command: #{command}"
  end
  response ? response : "No Response"
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
          response = execute_request(request,service,@cyberengine.defaults)
          request = request.map { |key,value| "#{key.capitalize}: #{value}" }.join("\r\n")

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
