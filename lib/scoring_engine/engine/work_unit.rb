require 'resque/plugins/status'

require 'timeout'
require 'open3'

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
            ::Open3.popen3(cmd_str) do |stdin, stdout, stderr, wait_thr|
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
          kill!
        end
        completed('output' => output)
      end
    end
  end
end