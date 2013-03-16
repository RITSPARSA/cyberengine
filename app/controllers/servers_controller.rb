class ServersController < ApplicationController
  before_filter :action_path
  def action_path; @action = params[:action].dup.prepend("can_").concat("?").to_sym end
  def authorized?(resource) error_redirect unless resource.send(@action,current_member,@team.id) end

  before_filter :read_path
  def read_path
    @team = Team.find_by_id(params[:team_id]) 
    redirect_to teams_path, alert: "Team #{params[:team_id]} does not exist" if @team.nil?
  end
 
  def show
    @server = Server.find_by_id(params[:id])
    authorized?(@server)
  end

  def new
    error_redirect unless Server.can_new?(current_member,@team.id)
    @server = Server.new
  end

  def edit
    @server = Server.find_by_id(params[:id])
    authorized?(@server)
  end

  def create
    @server = Server.new(params[:server])
    authorized?(@server)
    if @server.save
      redirect_to team_server_path(@team,@server), notice: 'Server was successfully created' 
    else
      render action: "new" 
    end
  end

  def update
    @server = Server.find_by_id(params[:id])
    authorized?(@server)
    if @server.update_attributes(params[:server])
      redirect_to team_server_path(@team,@server), notice: 'Server was successfully updated' 
    else
      render action: "edit" 
    end
  end

  def destroy
    @server = Server.find_by_id(params[:id])
    authorized?(@server)
    @server.destroy
    redirect_to team_path(@team), notice: 'Server was successfully deleted' 
  end
end
