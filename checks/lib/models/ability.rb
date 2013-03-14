class Ability
  include CanCan::Ability

  def initialize(member)
    @member = member
    @member ||= Member.new
    if @member && @member.team
      if @member.team.color == 'White' 
        whiteteam 
      elsif @member.team.color == 'Blue' 
        blueteam 
      elsif @member.team.color == 'Red' 
        redteam 
      else
        guest
      end
    else
      guest
    end
  end

  def whiteteam
    can :manage, :all
  end

  def blueteam
    # Basic permissions for everyone
    can [:new, :create, :destroy], :session
    can [:welcome, :scoreboard], :static
    can [:index, :overview], Team

    # Member's Team
    can [:show], Team, { id: @member.team_id }
    can [:show, :index], Server, team: { id: @member.team_id }
    can [:show, :index], Service, team: { id: @member.team_id }, enabled: true 
    can [:index, :show, :modal], Check, team: { id: @member.team_id }
    can [:index, :show, :modal], Property, team: { id: @member.team_id }, visible: true
    can [:index, :show, :modal, :edit, :update, :csv], User, team: { id: @member.team_id }

    # Uncomment to allow username changes
    # can [:update_usernames], User, team: { id: @member.team_id } 

    # Allow viewing from overview only
    # can [:modal], User
    # can [:modal], Property
    # can [:modal], Check
  end

  def redteam
    # Basic permissions for everyone
    can [:new, :create, :destroy], :session
    can [:welcome, :scoreboard], :static
    can [:index, :overview], Team

    # Allow viewing from overview only
    # can [:modal], User
    # can [:modal], Property
    # can [:modal], Check
  end

  def guest
    # Basic permissions for everyone
    can [:new, :create, :destroy], :session
    can [:welcome, :scoreboard], :static
    can [:index, :overview], Team

    # Allow viewing from overview only
    # can [:modal], User
    # can [:modal], Property
    # can [:modal], Check
  end

end
