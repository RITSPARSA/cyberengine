class ServicesController < ApplicationController
  before_filter :action_path
  def action_path; @action = params[:action].dup.prepend("can_").concat("?").to_sym end
  def authorized?(resource) error_redirect unless resource.send(@action,current_member,@team.id) end

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id]) 
    redirect_to teams_path, alert: "Team #{params[:team_id]} does not exist" if @team.nil?
    @server = Server.find_by_id(params[:server_id]) 
    redirect_to team_path(@team), alert: "Server #{params[:server_id]} does not exist" if @server.nil?
  end

  def show
    @service = Service.find_by_id(params[:id])
    authorized?(@service)
  end

  def new
    error_redirect unless Service.can_new?(current_member,@team.id)
    @service = Service.new
  end

  def edit
    @service = Service.find_by_id(params[:id])
    authorized?(@service)
  end

  def create
    @service = Service.new(params[:service])
    authorized?(@service)
    if @service.save
      redirect_to team_path(@team), notice: 'Service was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @service = Service.find_by_id(params[:id])
    authorized?(@service)
    if @service.update_attributes(params[:service])
      redirect_to team_path(@team), notice: 'Service was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @service = Service.find_by_id(params[:id])
    authorized?(@service)
    @service.destroy
    redirect_to team_path(@team), notice: 'Service was successfully deleted'
  end
end
