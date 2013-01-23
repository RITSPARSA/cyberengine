class ChecksController < ApplicationController
  load_and_authorize_resource

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id]) if params[:team_id]
    @server = Server.find_by_id(params[:server_id]) if params[:server_id]
    @service = Service.find_by_id(params[:service_id]) if params[:service_id]
  end

  def index
    if @service
      @checks = Check.where(service_id: @service.id)
    elsif @server
      @checks = Check.where(server_id: @server.id) if @server
    else 
      @checks = Check.where(team_id: @team.id) if @team
    end
  end

  def show
    @check = Check.find(params[:id])
  end

  def new
    @check = Check.new
  end

  def edit
    @check = Check.find(params[:id])
  end

  def create
    @check = Check.new(params[:check])
    if @check.save
      redirect_to team_server_service_checks_path(@team,@server,@service), notice: 'Check was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @check = Check.find(params[:id])
    if @check.update_attributes(params[:check])
      redirect_to team_server_service_checks_path(@team,@server,@service), notice: 'Check was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @check = Check.find(params[:id])
    @check.destroy
    redirect_to team_server_service_checks_path(@team,@server,@service)
  end

  layout false, only: [:modal]
  def modal
    if params[:id]
      @check = Check.find_by_id(params[:id])
    else
      @check = @service.checks.latest || Check.new
    end
  end
end
