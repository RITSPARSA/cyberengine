class StaticController < ApplicationController
  authorize_resource class: false
  def welcome
  end
  def scoreboard
  end
end
