require 'resque/plugins/status'

require 'timeout'
require "open4"

module ScoringEngine
  module Engine
    class WorkUnit
      @queue = "score_checks"

      include Resque::Plugins::Status

      def perform
        cmd_str = options['cmd']
        round = options['round']

        sleep 0.2
        puts "Running #{cmd_str} for round #{round}"

        output = ""
        pid = nil
        begin
          Timeout::timeout(Machine::CHECK_MAX_TIMEOUT) do
            status = Open4.popen4(cmd_str) do |in_pid, stdin, stdout, stderr|
              pid = in_pid
              while line = stdout.gets
                output << line
              end

              while line = stderr.gets
                output << line
              end
            end
          end
        rescue Timeout::Error
          puts "Timeout reached at #{Machine::CHECK_MAX_TIMEOUT}"
          Process.kill('TERM', pid)
          kill!
        end
        completed('output' => output)
      end
    end
  end
end