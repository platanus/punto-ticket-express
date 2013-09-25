module SidebarHelper

  def active_if_account
    if params[:controller] == "configuration" and
      (params[:action] == "account" or params[:action] == "update_account")
      return "active"
    end
  end

  def active_if_transaction
    if params[:controller].include? "transactions" or
      params[:action] == "transactions" or
      params[:controller].include? "tickets"
      return "active"
    end
  end

  def active_if_producer
    if params[:controller].include? "producers" or
      params[:action] == "producers"
      return "active"
    end
  end

  def active_if_event
    if params[:controller].include? "events" and
      (params[:action] == "edit" or params[:action] == "new" )
      return "active"
    end
  end

  def active_if_form
    if params[:controller].include? "events" and
      params[:action] == "data_to_collect"
      return "active"
    end
  end

  def active_if_event_statistic
    if params[:controller].include? "events" and
      params[:action] == "sold_tickets"
      return "active"
    end
  end

  def active_if_participants
    if params[:controller].include? "events" and
      params[:action] == "participants"
      return "active"
    end
  end

end
