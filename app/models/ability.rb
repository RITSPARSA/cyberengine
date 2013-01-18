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
    can [:new, :create, :destroy], :session
    can [:index, :show, :overview], Team
    can [:index, :show], Server
    can [:index, :show, :modal_properties, :modal_users, :modal_latest_check], Service
    can [:index, :show], Property
    can [:index], Check
    can [:show], Check, service: { server: { team_id: @member.team_id } }
    can [:index, :show], User
  end

  def redteam
    can [:new, :create, :destroy], :session
    can [:index, :show, :overview], Team
    can [:index, :show, :properties], Server
    can [:index, :show, :properties], Service
    can [:index, :show, :modal], Property
    can [:index], Check
    can [:show], Check, service: { server: { team_id: @member.id } }
    can [:index, :show], User
  end

  def guest
    can [:new, :create, :destroy], :session
    can [:index, :show, :overview], Team
    can [:index, :show, :properties], Server
    can [:index, :show, :properties], Service
    can [:index, :show], Server
    can [:index, :show, :modal], Property
    can [:index], Check
    can [:show], Check, service: { server: { team_id: @member.id } }
    can [:index, :show], User
  end

end
