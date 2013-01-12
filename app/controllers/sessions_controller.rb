class SessionsController < ApplicationController
  def new
    # Rendering new page
  end

  def create
    username = params[:session][:username] || ''
    password = params[:session][:password] || ''
    member = Member.find_by_username(username)
    if member && member.authenticate(password)
      session[:member_id] = member.id
      redirect_to team_path(member.team_id), :notice => "Successfully logged in"
    else
      flash.now.alert = "Invalid username or password"
      redirect_to new_session_path, :alert => "Invalid username or password"
    end
  end

  def destroy
    session[:member_id] = nil
    redirect_to teams_path, :notice => "Successfully logged out"
  end
end
