class UsersController < ApplicationController
  load_and_authorize_resource

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id])
    @server = Server.find_by_id(params[:server_id])
    @service = Service.find_by_id(params[:service_id])
  end

  def index
    @users = User.where(service_id: @service.id)
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def csv
    if params[:csv]
      csv = params[:csv]
      users_list = Array.new
      users = User.where(service_id: @service.id)
      passed = Array.new
      unknown = Array.new
      failed = Array.new
      csv.gsub!(/(\r\n)+/,"\r\n")
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
    @users = User.where(service_id: @service.id).map{|u| "#{u.username},#{u.password}"}.join("\r\n")
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to team_server_service_users_path(@team,@server,@service), notice: 'User was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @user = User.find(params[:id])
    username = params[:user][:username] if params[:user][:username]
    params[:user][:username] ?  username = params[:user][:username] : username = nil
    if can?(:update_usernames, @user) || username == @user.username || username.nil?
      if @user.update_attributes(params[:user])
        redirect_to team_server_service_users_path(@team,@server,@service), notice: 'User was successfully updated'
      else
        render action: "edit"
      end
    else
      flash.now[:warning] = "Cannot change usernames"
      render action: "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to team_server_service_users_path(@team,@server,@service), notice: 'User was successfully deleted'
  end

  layout false, only: [:modal]
  def modal
    if @service
      @users = @service.users
    else
      @users = @server.users
    end
    if @users.count == 0
      render(partial: 'modal_empty')
    else
      render(partial: 'modal_users')
    end
  end
end
