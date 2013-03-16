class TeamsController < ApplicationController
  before_filter :action_path
  def action_path; @action = params[:action].dup.prepend("can_").concat("?").to_sym end
  def authorized?(resource) error_redirect unless resource.send(@action,current_member,@team.id) end

  def index
    @teams = Team.order('id')
  end

  def overview
    @teams = Team.blueteams.ordered
  end

  def show
    @team = Team.find_by_id(params[:id])
    authorized?(@team)
  end

  def new
    error_redirect unless Team.can_new?(current_member)
    @team = Team.new
  end

  def edit
    @team = Team.find_by_id(params[:id])
    authorized?(@team)
  end

  def create
    @team = Team.new(params[:team])
    authorized?(@team)
    if @team.save
      redirect_to team_path(@team), notice: 'Team was successfully created' 
    else
      render action: "new" 
    end
  end

  def update
    @team = Team.find_by_id(params[:id])
    authorized?(@team)
    if @team.update_attributes(params[:team])
      redirect_to team_path(@team), notice: 'Team was successfully updated' 
    else
      render action: "edit" 
    end
  end

  def destroy
    @team = Team.find_by_id(params[:id])
    authorized?(@team)
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully deleted'
  end
 
end
