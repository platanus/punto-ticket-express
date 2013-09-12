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

  def attr_is_checked(attr_name, is_required)
  	attr = @event.data_to_collect.detect { |h| h[:name].to_s == attr_name.to_s}
  	return false if attr.nil? or attr.empty?
  	if is_required
  		return attr[:required]
  	else
  		return attr[:required] == false
  	end
  end

end
