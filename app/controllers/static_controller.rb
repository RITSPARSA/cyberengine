class StaticController < ApplicationController
  authorize_resource class: false

  def welcome
  end

  def scoreboard
    @linegraph = Array.new
    @rounds = Check.select('round').uniq.map{|c| c.round}
    Team.blueteams.each do |team|
      hash = Hash.new
      hash[:name] = team.alias
      hash[:data] = team.checks.linegraph
      @linegraph << hash
    end
  end
end
