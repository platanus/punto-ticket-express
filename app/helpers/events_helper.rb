module EventsHelper
  def form_url(event)
    event.new_record? ? new_event_path : edit_event_path(id: event.id)
  end

  def disabled_class
  	@event.new_record? ? 'disabled' : ''
  end

  def disabled_if_published
     @event.is_published? ? 'disabled' : ''
  end

  def show_or_preview_button(event)
    label = "buttons.preview"
    label = "buttons.show" if event.is_published?
  	link_to(t(label), event)
  end

  def statistics_or_edit_button(event)
  	if event.is_published?
  		link_to t("buttons.statistics"), sold_tickets_event_path(event)
  	else
  		link_to t("buttons.edit"), edit_event_path(event)
  	end
  end

  def tickets_limit
    @event.sell_limit || GlobalConfiguration.sell_limit
  end
end
