require 'rubygems'        # if you use RubyGems
@root = File.dirname(__FILE__)
@pids = @root + '/pids'
@logs = @root + '/logs'
log = "/root/cyberengine/checks/tmp/logs/control.log"
#options = {STDERR=>STDOUT, STDOUT=>["/root/cyberengine/checks/tmp/logs/control.log", "a"] }
options = {[:out, :err]=>[log, "w"]}
options = {:out=>[log, "a"], :err=>[log, "a"] }
pid = Process.spawn('/root/cyberengine/checks/tmp/check.rb',options)
#wait(pid,1)
puts "PID = #{pid}"
sleep 1
Process.detach(pid)
sleep 1
Process.kill('TERM',pid)
