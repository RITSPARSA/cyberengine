#!/usr/bin/env ruby
count = 1
log = '/root/cyberengine/checks/tmp/logs/check.log'
File.open(log,'a') {|f| f.puts(Time.now) }
term = false
Process.daemon()
Signal.trap("TERM") { 
  File.open(log,'a') {|f| f.puts("TERM") }; term=true
  puts "TERM"
 }

loop do
  count +=1
  File.open(log,'a') {|f| f.puts(Process.pid) }
  puts Time.now
  sleep(0.2)
  raise "ERROR" if count == 100 || term
end
