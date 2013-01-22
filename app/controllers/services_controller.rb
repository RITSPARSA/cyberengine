class ServicesController < ApplicationController
  load_and_authorize_resource
  layout false, only: [:modal_properties, :modal_latest_check, :modal_users]
  before_filter :get_team

  def get_team
    @team = Team.find_by_id(params[:team_id]) 
  end

  def index
    @services = Service.where(team_id: @team.id)
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
      redirect_to team_services_path(@team), notice: 'Service was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @service = Service.find(params[:id])
    if @service.update_attributes(params[:service])
      redirect_to team_services_path(@team), notice: 'Service was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @service = Service.find(params[:id])
    @service.destroy
    redirect_to team_services_path(@team), notice: 'Service was successfully deleted'
  end

  def modal_properties
    @service = Service.find(params[:id])
    @properties = @service.properties
  end

  def modal_latest_check
    @service = Service.find(params[:id])
    @check = @service.checks.latest
  end

  def modal_users
    @service = Service.find(params[:id])
    @users = @service.users
  end

end
