require 'spec_helper'
require 'scoring_engine/check_collection'

module ScoringEngine

  describe CheckCollection do
    context 'when creating collection with good check directory' do
      before :each do
        collection_dir = File.join(File.dirname(__FILE__), 'fake_checks')
        @collection = ScoringEngine::CheckCollection.new(collection_dir)
      end

      it 'should set check location correctly' do
        expect(@collection.checks_location).to match(/spec\/fake_checks$/)
      end

      it 'should parse expected number of checks' do
        known_checks = [ScoringEngine::Checks::HTTP, ScoringEngine::Checks::ICMP]
        expect(@collection.checks).to eq(known_checks)
      end

    end

    context 'when creating collection with non existent check directory' do
      it 'should throw error' do
        expect{ScoringEngine::CheckCollection.new("abc")}.to raise_error(Exceptions::BadCheckLocation)
      end

    end
  end

end
