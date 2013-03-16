class SessionsController < ApplicationController
  def new; end

  def create
    username = params[:session][:username] || ''
    password = params[:session][:password] || ''
    member = Member.find_by_username(username)
    if member && member.authenticate(password)
      session[:member_id] = member.id
      if member.blueteam?
        redirect_to team_path(member.team_id), notice: "Successfully logged in"
      else
        redirect_to teams_path, notice: "Successfully logged in"
      end
    else
      redirect_to new_session_path, alert: "Invalid username or password"
    end
  end

  def destroy
    unless current_member.id == session[:member_id]
      redirect_to teams_path, warn: "Now your getting the idea"
    end 
    session[:member_id] = nil
    redirect_to teams_path, notice: "Successfully logged out"
  end
end
