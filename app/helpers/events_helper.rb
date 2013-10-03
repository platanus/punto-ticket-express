module EventsHelper
  def form_url(event)
    event.new_record? ? new_event_path : edit_event_path
  end

  def disabled_class
  	@event.new_record? ? 'disabled' : ''
  end

  def show_url_or_preview(event)
  	if event.is_published?
  		link_to(t("buttons.show"), event, :class => 'btn btn-mini')
  	else
  		link_to(t("buttons.show"), event_path(event, :preview => 'true'), :class => 'btn btn-mini')
  	end
  end

  def analytics_or_edit_url(event)
  	if event.is_published?
  		link_to t("buttons.edit"), sold_tickets_event_path(event), :class => 'btn btn-mini'
  	else
  		link_to t("buttons.edit"), edit_event_path(event), :class => 'btn btn-mini'
  	end
  end
end
