class Ability
  include CanCan::Ability

  def initialize(member)
    # can [:index, :show, :new, :create, :update, :edit, :destroy], [Session]
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
    can [:index, :show], Service
    can [:index], User

    # Restrictions
    can [:show], Team, color: 'blue' # Shows team in index

    # Owner 
    can [:show], Check, service: { server: { team_id: @member.team_id } }
    can [:show], Property, service: { server: { team_id: @member.team_id } }
    can [:update_username], User, service: { server: { team_id: @member.team_id } }
    can [:show, :edit, :update], User, service: { server: { team_id: @member.team_id } }
    can [:modal_properties, :modal_users, :modal_latest_check], Service, server: { team_id: @member.team_id } 
  end

  def redteam
    can :manage, :all
  end

  def guest
    can :manage, :all
  end

end
