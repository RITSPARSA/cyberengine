class ApplicationController < ActionController::Base
  protect_from_forgery
  check_authorization

  private

  def current_member
    if session[:member_id]
      @current_member = Member.find_by_id(session[:member_id]) || nil
    else
      @current_member = nil
    end
    @current_member
  end

  def logged_in?
    @current_member
  end

  def whiteteam?
    @current_member if @current_member && @current_member.team && @current_member.team.color == "white"
  end

  def redteam?
    @current_member if @current_member && @current_member.team && @current_member.team.color == "red"
  end

  def blueteam?
    @current_member if @current_member && @current_member.team && @current_member.team.color == "blue"
  end

  def member?(team)
    @current_member if team && @current_member && @current_member.team_id == team.id
  end

  alias_method :current_user, :current_member
  helper_method :current_member, :logged_in?, :current_user
  helper_method :whiteteam?, :redteam?, :blueteam?, :member?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

end
