require 'spec_helper'
require 'scoring_engine'

module ScoringEngine

  describe Config do
    context 'parsing an example config' do
      before :each do
        fake_config = File.join(File.dirname(__FILE__), 'fake_config.yaml')
        @config = ScoringEngine::Config.new(fake_config)
      end

      context 'should access config values via []' do
        it 'should return value using good config key' do
          expect(@config["checks_location"]).to eq("/test/location/checks")
        end

        it 'should throw error using bad key' do
          expect{@config["some_known_key"]}.to raise_error(Exceptions::ConfigValueNotFound)
        end
      end
    end

    context 'parsing a non existant config file' do
      it 'should throw error' do
        expect{ScoringEngine::Config.new("abc")}.to raise_error(Errno::ENOENT)
      end
    end
  end

end
