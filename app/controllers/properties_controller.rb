class PropertiesController < ApplicationController
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
    @property = Property.find_by_id(params[:id])
    authorized?(@property)
  end

  def new
    error_redirect unless Property.can_new?(current_member,@team.id)
    @property = Property.new
  end

  def edit
    @property = Property.find_by_id(params[:id])
    authorized?(@property)
  end

  def create
    @property = Property.new(params[:property])
    authorized?(@property)
    if @property.save
      redirect_to team_server_service_path(@team,@server,@service), notice: 'Property was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @property = Property.find_by_id(params[:id])
    authorized?(@property)
    if @property.update_attributes(params[:property])
      redirect_to team_server_service_path(@team,@server,@service), notice: 'Property was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @property = Property.find_by_id(params[:id])
    authorized?(@property)
    @property.destroy
    redirect_to team_server_service_path(@team,@server,@service), notice: 'Property was successfully deleted'
  end

  layout false, only: [:modal]
  def modal
    @action = :can_show?
    @properties = @service ? @service.properties : @server.properties
    current_member.can_overview_properties? || authorized?(@properties)
    @properties.count == 0 ? render(partial: 'modal_empty') : render(partial: 'modal_properties')
  end
end
