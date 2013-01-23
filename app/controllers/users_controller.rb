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

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to team_server_service_users_path(@team,@server,@service), notice: 'User was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @user = User.find(params[:id])
    unless can? :update_usernames, @user
      params[:user].delete(:username) if params[:user][:username] 
    end
    if @user.update_attributes(params[:user])
      redirect_to team_server_service_users_path(@team,@server,@service), notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to team_server_service_users_path(@team,@server,@service)
  end

  layout false, only: [:modal]
  def modal
  end

end
