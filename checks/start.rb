#!/usr/bin/env ruby

# This files directory
root = File.dirname(__FILE__)

# Path to checks
paths = Array.new
paths << root + '/ipv4/*'
paths << root + '/ipv6/*'

# Simple threading manager
threads = []

# Checks to exclude (full relative path required)
# This is useful if a check is messed up and needs debugging
# Example: exclude = [ './ipv4/ping.rb' ] 
exclude = [] 

# IPv4 Checks
Dir.glob(paths) do |check|
  next if exclude.include?(check)
  # Start script in thread
  # DEBUG output available in logs (mostly SQL)
  threads << Thread.new { puts `#{check} | grep -v DEBUG` }    
end

# Wait for threads to finish
threads.each {|thread| thread.join }

