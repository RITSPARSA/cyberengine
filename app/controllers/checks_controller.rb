class ChecksController < ApplicationController
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
    redirect_to team_server_path(@team,@server), alert: "Service #{params[:service_id]} does not exist" if @service.nil? && params[:action] 
  end

  def show
    @check = Check.find(params[:id])
    #@check = Check.find_by_id(params[:id])
    authorized?(@check)
  end

  def new
    error_redirect unless Check.can_new?(current_member,@team.id)
    @check = Check.new
  end

  def edit
    @check = Check.find_by_id(params[:id])
    authorized?(@check)
  end

  def create
    @check = Check.new(params[:check])
    authorized?(@check)
    if @check.save
      redirect_to team_server_service_path(@team,@server,@service), notice: 'Check was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @check = Check.find_by_id(params[:id])
    authorized?(@check)
    if @check.update_attributes(params[:check])
      redirect_to team_server_service_path(@team,@server,@service), notice: 'Check was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @check = Check.find_by_id(params[:id])
    authorized?(@check)
    @check.destroy
    redirect_to team_server_service_path(@team,@server,@service), notice: 'Check was successfully deleted'
  end

  layout false, only: [:modal]
  def modal
    @action = :can_show?
    @check = Check.find_by_id(params[:id])
    authorized?(@check)
    @check.nil? ? render(partial: 'modal_empty') : render(partial: 'modal_check')
  end

end
