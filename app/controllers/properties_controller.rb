class PropertiesController < ApplicationController
  load_and_authorize_resource

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id])
    @server = Server.find_by_id(params[:server_id])
    @service = Service.find_by_id(params[:service_id])
  end

  def index
    @properties = Property.where(service_id: @service.id)
  end

  def show
    @property = Property.find(params[:id])
  end

  def new
    @property = Property.new
  end

  def edit
    @property = Property.find(params[:id])
  end

  def create
    @property = Property.new(params[:property])
    if @property.save
      redirect_to team_server_service_properties_path(@team,@server,@service), notice: 'Property was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @property = Property.find(params[:id])
    if @property.update_attributes(params[:property])
      redirect_to team_server_service_properties_path(@team,@server,@service), notice: 'Property was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @property = Property.find(params[:id])
    @property.destroy
    redirect_to team_server_service_properties_path(@team,@server,@service), notice: 'Property was successfully deleted'
  end

  layout false, only: [:modal]
  def modal
    if @service
      @properties = @service.properties
    else
      @properties = @server.properties
    end
    if @properties.count == 0
      render(partial: 'modal_empty')
    else
      render(partial: 'modal_properties')
    end
  end
end
