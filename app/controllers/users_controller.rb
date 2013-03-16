class UsersController < ApplicationController
  before_filter :action_path
  def action_path; @action = params[:action].dup.prepend("can_").concat("?").to_sym end
  def authorized?(resource) error_redirect unless resource.send(@action,current_member,@team.id) end

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id])
    redirect_to teams_path, alert: "Team #{params[:team_id]} does not exist" if @team.nil?
    @server = Server.find_by_id(params[:server_id])
    redirect_to team_path(@team), alert: "Server #{params[:server_id]} does not exist" if @server.nil?
    @service = Service.find_by_id(params[:service_id])
    redirect_to team_server_path(@team,@server), alert: "Service #{params[:service_id]} does not exist" if @service.nil? && params[:action] != 'modal'
  end

  def show
    @user = User.find_by_id(params[:id])
    authorized?(@user)
  end

  def new
    error_redirect unless User.can_new?(current_member,@team.id)
    @user = User.new
  end

  def edit
    @user = User.find_by_id(params[:id])
    authorized?(@user)
  end

  def csv
    @action = :can_edit?
    if params[:csv]
      csv = params[:csv]
      users_list = Array.new
      users = User.where(service_id: @service.id)
      authorized?(users)
      passed = Array.new
      unknown = Array.new
      failed = Array.new
      csv.gsub!(/(\r?\n)+/,"\r\n")
      csv.split.each do |csv_user| 
        split = csv_user.split(',',2)
        users_list << { username: split.first, password: split.last }
      end
      users_list.each do |hash|
        username = hash[:username]
        password = hash[:password]
        user = users.where('username = ?', username).first
        if user
          user.update_attributes(password: password)
          if user.save 
            passed << username 
          else 
            failed << "#{username} [#{user.errors.full_messages.join(',')}]"
          end
        else
          unknown << username
        end
      end
      flash.now[:success] = "Updated: #{passed.join(', ')}" unless passed.empty?
      flash.now[:error] = "Failed: #{failed.join(', ')}" unless failed.empty?
      flash.now[:info] = "Unknown username: #{unknown.join(', ')}" unless unknown.empty?
    end
    @users = User.where(service_id: @service.id)
    authorized?(@users)
  end

  def create
    @user = User.new(params[:user])
    authorized?(@user)
    if @user.save
      redirect_to team_server_service_path(@team,@server,@service), notice: 'User was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @user = User.find_by_id(params[:id])
    authorized?(@user)
    username = params[:user][:username] if params[:user][:username]
    params[:user][:username] ?  username = params[:user][:username] : username = nil
    if Blueteam.can_update_usernames || username == @user.username || username.nil?
      if @user.update_attributes(params[:user])
        redirect_to team_server_service_path(@team,@server,@service), notice: 'User was successfully updated'
      else
        render action: "edit"
      end
    else
      flash.now[:warning] = "Cannot change usernames"
      render action: "edit"
    end
  end

  def destroy
    @user = User.find_by_id(params[:id])
    authorized?(@user)
    @user.destroy
    redirect_to team_server_service_path(@team,@server,@service), notice: 'User was successfully deleted'
  end

  layout false, only: [:modal]
  def modal
    @action = :can_show?
    @users = @service ? @service.users : @server.users
    current_member.can_overview_properties? || authorized?(@users)
    @users.count == 0 ? render(partial: 'modal_empty') : render(partial: 'modal_users')
  end
end
