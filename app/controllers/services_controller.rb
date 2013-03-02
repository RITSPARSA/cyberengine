class ServicesController < ApplicationController
  load_and_authorize_resource

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id]) 
    @server = Server.find_by_id(params[:server_id]) 
  end

  def index
  end

  def show
    @service = Service.find(params[:id])
  end

  def new
    @service = Service.new
  end

  def edit
    @service = Service.find(params[:id])
  end

  def create
    @service = Service.new(params[:service])
    if @service.save
      redirect_to team_server_services_path(@team,@server), notice: 'Service was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @service = Service.find(params[:id])
    if @service.update_attributes(params[:service])
      redirect_to team_server_services_path(@team,@server), notice: 'Service was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @service = Service.find(params[:id])
    @service.destroy
    redirect_to team_server_services_path(@team,@server), notice: 'Service was successfully deleted'
  end
end
