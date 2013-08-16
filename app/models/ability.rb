class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    
    if user.admin?
      can :manage, :all

    elsif user.organizer?
      #EVENTS
      can :have, :events
      can :create, Event
      can :read, Event
      #organizer can update his events only
      can :update, Event do |event|
        event.user_id == user.id
      end
      can :destroy, Event do |event|
        event.user_id == user.id
      end
      #TICKETS
      can :create, Ticket
      #organizer can see sold tickets for his events
      can :read, Ticket do |ticket|
        ticket.event_user_id == user.id
      end

    elsif user.participant?
      #EVENTS
      can :read, Event
      #TICKETS
      can :create, Ticket
      #participant can see his purchased tickets
      can :read, Ticket do |ticket|
        ticket.user_id == user.id
      end
    end    
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
