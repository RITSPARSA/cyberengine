class MembersController < ApplicationController
  before_filter :action_path
  def action_path; @action = params[:action].dup.prepend("can_").concat("?").to_sym end
  def authorized?(resource) error_redirect unless resource.send(@action,current_member) end

  def index
    @members = Member.order('team_id ASC')
    authorized?(@members)
  end

  def show
    @member = Member.find_by_id(params[:id])
    authorized?(@member)
  end

  def new
    error_redirect unless Member.can_new?(current_member)
    @member = Member.new
  end

  def edit
    @member = Member.find_by_id(params[:id])
    authorized?(@member)
  end

  def create
    @member = Member.new(params[:member])
    authorized?(@member)
    if @member.save
      redirect_to members_path, notice: 'Member was successfully created'
    else
      render action: "new"
    end
  end

  def update
    @member = Member.find_by_id(params[:id])
    authorized?(@member)
    if @member.update_attributes(params[:member])
      redirect_to members_path, notice: 'Member was successfully updated'
    else
      render action: "edit"
    end
  end

  def destroy
    @member = Member.find_by_id(params[:id])
    authorized?(@member)
    @member.destroy
    redirect_to members_path, notice: 'Member was successfully deleted'
  end
end
