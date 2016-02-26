class RedisController < ApplicationController
  def authorized?; error_redirect unless current_member.whiteteam?;end

  def redis
    authorized?
  end
end