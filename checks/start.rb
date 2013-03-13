#!/usr/bin/env ruby


# This files directory
root = File.dirname(__FILE__)


# Path to checks
# Comment out unwanted paths (aka no IPv6 checks)
# Alternitely the checks could be renamed to <check>.disabled
paths = Array.new
paths << root + '/ipv4/*' 
paths << root + '/ipv6/*'


# Simple threading manager
threads = []


# HOW TO DISABLE A CHECK
# simply rename the check to <anything>.disabled
# Example: ftp-upload.rb.disabled


Dir.glob(paths) do |check|
  next if check =~ /.disabled?\z/ # .disabled or .disable
  # Start script in thread
  # DEBUG output available in logs (mostly SQL)
  threads << Thread.new { puts `#{check} | grep -v DEBUG` }    
end


# Wait for threads to finish
threads.each {|thread| thread.join }
