module EventsHelper
  def form_url(event)
    event.new_record? ? new_event_path : edit_event_path(id: event.id)
  end

  def disabled_class
  	@event.new_record? ? 'disabled' : ''
  end

  def show_or_preview_button(event)
  	if event.is_published?
  		link_to(t("buttons.show"), event, :class => 'btn btn-mini btn-mini-in-line')
  	else
  		link_to(t("buttons.preview"), event_path(event, :preview => 'true'), :class => 'btn btn-mini btn-mini-in-line')
  	end
  end

  def statistics_or_edit_button(event)
  	if event.is_published?
  		link_to t("buttons.statistics"), sold_tickets_event_path(event), :class => 'btn btn-mini btn-mini-in-line'
  	else
  		link_to t("buttons.edit"), edit_event_path(event), :class => 'btn btn-mini btn-mini-in-line'
  	end
  end
end
