class ApplicationController < ActionController::Base
  protect_from_forgery

  private
  def current_member
    current_member ||= Member.find(session[:member_id]) if session[:member_id]
  end
  alias_method :logged_in?, :current_member
  alias_method :logged_in?, :current_user
  helper_method :current_member, :logged_in?, :current_user

end
