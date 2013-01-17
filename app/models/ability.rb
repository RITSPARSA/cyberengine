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
    can [:index, :show], Team
    can [:index, :show], Server
    can [:index, :show], Service
    can [:index, :show], Property
    can [:index, :show], Check
  end

  def redteam
    can [:new, :create, :destroy], :session
    can [:index, :show], Team
    can [:index, :show], Server
    can [:index, :show], Service
    can [:index, :show], Property
    can [:index, :show], Check
  end

  def guest
    can [:new, :create, :destroy], :session
    can [:index, :show], Team
    can [:index, :show], Server
    can [:index, :show], Service
    can [:index, :show], Property
    can [:index, :show], Check
  end

end
