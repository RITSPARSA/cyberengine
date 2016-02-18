module ScoringEngine
  module Engine

    module Exceptions

      class BadCheckLocation < StandardError;end

      class MultipleIPProperties < StandardError;end

      class TerminateEngine < StandardError;end

    end
  end

end