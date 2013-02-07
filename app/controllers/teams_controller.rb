class TeamsController < ApplicationController
  load_and_authorize_resource 

  def index
    @teams = Team.all
  end

  def overview
    @teams = Team.blueteams
  end

  def show
    @team = Team.find(params[:id])
  end

  def new
    @team = Team.new
  end

  def edit
    @team = Team.find(params[:id])
  end

  def create
    @team = Team.new(params[:team])
    if @team.save
      redirect_to @team, notice: 'Team was successfully created' 
    else
      render action: "new" 
    end
  end

  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(params[:team])
      redirect_to @team, notice: 'Team was successfully updated' 
    else
      render action: "edit" 
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to teams_url, notice: 'Team was successfully deleted'
  end
end
