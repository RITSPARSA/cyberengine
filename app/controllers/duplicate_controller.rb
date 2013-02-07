class DuplicateController < WhiteteamController 
  skip_authorization_check only: [:checks]
  before_filter :whiteteam_only
  def whiteteam_only
    redirect_to teams_path unless current_member.team.color == "white"
  end

  def checks
    @checks = Check.all
  end

end
