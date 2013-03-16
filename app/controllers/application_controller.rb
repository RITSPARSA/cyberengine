class ApplicationController < ActionController::Base
  protect_from_forgery

  def current_member
    if session[:member_id] && @current_member.nil?
      @current_member = Member.find_by_id(session[:member_id]) 
    end
    if @current_member.nil?
      @current_member = Member.new
      @current_member.team = Team.new
    end
    @current_member
  end

  def error_redirect
    redirect_to teams_path, alert: "You are not authorized to access that page."
  end

  helper_method :current_member
end
