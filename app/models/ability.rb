class Ability
  include CanCan::Ability

  def initialize(member)
    @member = member
    @member ||= Member.new
    if @member && @member.team
      if @member.team.color == 'white' 
        whiteteam 
      elsif @member.team.color == 'blue' 
        blueteam 
      elsif @member.team.color == 'red' 
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
    # Everyone
    can [:new, :create, :destroy], :session
    can [:index, :overview], Team
    can [:index, :show], Server
    can [:index], Service

    # Restrictions
    can [:show], Team, color: 'blue' # Shows only  blueteams in index

    # Owner 
    can [:show], Service, server: { team_id: @member.team_id } 
    can [:index, :show, :modal], Check, service: { server: { team_id: @member.team_id } }
    can [:index, :show, :modal], Property, service: { server: { team_id: @member.team_id } } 
    can [:index, :show, :modal, :edit, :update], User, service: { server: { team_id: @member.team_id } } # add ":update_usernames" to enable username changes
  end

  def redteam
    can [:new, :create, :destroy], :session
    can [:index, :overview], Team
    can [:index, :show], Server
    can [:index], Service
    can [:show], Team, color: ['blue','red'] # Shows only  blueteams in index
  end

  def guest
    can [:welcome], :static
    can [:new, :create, :destroy], :session
    can [:index, :overview], Team
    can [:index, :show], Server
    can [:index], Service
    can [:show], Team, color: 'blue' # Shows only  blueteams in index
  end

end
