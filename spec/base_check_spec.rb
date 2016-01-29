require 'spec_helper'
require 'scoring_engine/base_check'

module ScoringEngine

  module Checks
    describe BaseCheck do
      context 'Creating a new check' do
        before :each do
          @check = ScoringEngine::Checks::BaseCheck.new("127.0.0.1")
        end

        it 'should set server ip to correct ip' do
          expect(@check.server_ip).to eq("127.0.0.1")
        end

      end
      context "Static methods" do
        it 'should return good clean name' do
          expect(ScoringEngine::Checks::BaseCheck.clean_name).to eq("BaseCheck")
        end
      end
    end

  end
end
