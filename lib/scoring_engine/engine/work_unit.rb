require 'resque/plugins/status'
require 'pty'
require 'timeout'

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
        begin
          Timeout::timeout(Machine::CHECK_MAX_TIMEOUT) do
            ::PTY.spawn(cmd_str) do |irb_out, irb_in, pid|
              output = irb_out.readlines.join("")
            end
          end
        rescue Timeout::Error
          puts "Timeout reached at #{Machine::CHECK_MAX_TIMEOUT}"
          kill!
        end
        completed('output' => output)
      end
    end
  end
end