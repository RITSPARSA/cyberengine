class ServersController < ApplicationController
  load_and_authorize_resource

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id]) 
  end
 
  def index
  end

  def show
    @server = Server.find(params[:id])
  end

  def new
    @server = Server.new
  end

  def edit
    @server = Server.find(params[:id])
  end

  def create
    @server = Server.new(params[:server])
    if @server.save
      redirect_to team_servers_path(@team), notice: 'Server was successfully created' 
    else
      render action: "new" 
    end
  end

  def update
    @server = Server.find(params[:id])
    if @server.update_attributes(params[:server])
      redirect_to team_servers_path(@team), notice: 'Server was successfully updated' 
    else
      render action: "edit" 
    end
  end

  def destroy
    @server = Server.find(params[:id])
    @server.destroy
    redirect_to team_servers_path(@team), notice: 'Server was successfully deleted' 
  end
end
