module EventsHelper

  def boolean_to_words(value)
    value ? "Yes" : "No"
  end

  def form_url(event)
    event.new_record? ? new_event_path : edit_event_path
  end

  def disabled_class
  	# !@event.is_published ? 'disabled' : ''
  	@event.new_record? ? 'disabled' : ''
  end


end
