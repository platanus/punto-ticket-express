module EventsHelper
  def form_url(event)
    event.new_record? ? new_event_path : edit_event_path
  end

  def disabled_class
  	@event.new_record? ? 'disabled' : ''
  end

  def my_even_url(event)
  	event.is_published ? sold_tickets_event_path(event) : edit_event_path(event)
  end
end
