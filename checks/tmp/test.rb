require 'active_record'
require 'active_support'
require_relative '../lib/cyberengine'

class Check < ActiveRecord::Base; end

    environments = YAML::load(File.open('../database.yml'))
    # Default to production then development
    #puts environments['production'] || environments['development']
    config = environments['production'] || environments['development']
    @connection = ActiveRecord::Base.establish_connection(config)

class Cyberengine::Check
end
puts 'ab cd'.url_encode
puts Cyberengine.stop
puts Cyberengine::Check.new
puts Check.first
