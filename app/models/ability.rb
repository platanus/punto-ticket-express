class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all

    elsif user.user?
      #CONFIGURATION
      can :config, :account
      can :config, :producers
      can :config, :transactions


      #EVENTS
      can :have, :events
      can :create, Event
      can :read, Event
      can :my_index, Event
      #user can update his events only
      can :update, Event do |event|
        event.user_id == user.id
      end
      can :dashboard, Event do |event|
        event.user_id == user.id
      end
      can :destroy, Event do |event|
        event.user_id == user.id
      end
      can :participants, Event do |event|
        event.user_id == user.id
      end
      can :data_to_collect, Event do |event|
        event.user_id == user.id
      end
      can :sold_tickets, Event do |event|
        event.user_id == user.id
      end


      #TICKETS
      #user can see his own tickets or sold tickets for his events
      can :read, Ticket do |ticket|
        (ticket.transaction_user_id == user.id) or (ticket.event_user_id == user.id)
      end
      can :download, Array do |tickets|
        tickets.each do |ticket|
          unless (ticket.transaction_user_id == user.id) or
            (ticket.event_user_id == user.id)
            return false
          end
        end
        true
      end


      #PRODUCERS
      can :create, Producer
      can :read, Producer do |producer|
        producer.user_ids.include? user.id
      end
      can :update, Producer do |producer|
        producer.user_ids.include? user.id
      end
      can :destroy, Producer do |producer|
        producer.user_ids.include? user.id
      end


      #TRANSACTIONS
      can :create, Transaction
      can :read, Transaction do |transaction|
        transaction.user_id == user.id
      end
    else
      can :read, Event
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
