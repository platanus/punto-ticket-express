module EventsHelper
  def form_url(event)
    event.new_record? ? new_event_path : edit_event_path(id: event.id)
  end

  def disabled_class_if_new_event
  	@event.new_record? ? 'disabled' : ''
  end

  def disabled_if_published_event
     @event.is_published? ? 'disabled' : ''
  end

  def disabled_if_new_or_unpublished_event
     (@event.new_record? || !@event.is_published?) ? 'disabled' : ''
  end

  def show_or_preview_event_action(event)
    label = "buttons.preview"
    label = "buttons.show" if event.is_published?
  	link_to(t(label), event, {:class => 'action-link'})
  end

  def statistics_or_edit_event_action(event)
  	if event.is_published?
  		link_to t("buttons.statistics"), sold_tickets_event_path(event), {:class => 'action-link'}
  	else
  		link_to t("buttons.edit"), edit_event_path(event), {:class => 'action-link'}
  	end
  end

  def delete_event_action event, current_tab
    link_to t('buttons.destroy'), event_path(id: event.id, current_tab: current_tab), :class => 'action-link', method: :delete, data: { confirm: t(".delete_message") }
  end

  def publish_event_action event
    form_tag publish_event_path(event), :method => :put, :style => "margin: 0px;" do
      button_tag 'Publicar evento' ,
        class: 'btn-link action-link' ,
        :disabled => event.is_past_event? || event.is_published,
        type: :submit
    end
  end

  def tickets_limit
    @event.sell_limit || GlobalConfiguration.sell_limit
  end

  def facebook_like_button event
    url = request.original_url
    src = "//www.facebook.com/plugins/like.php?href=#{url}&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=false&amp;share=true&amp;height=35"
    content_tag(:iframe, nil, src: src, scrolling: "no", frameborder: "0", style: "border:none; overflow:hidden; height:62px; width: 600px;", allowTransparency: "true")
  end

  def event_tabs_link(tab_name, link_path, current_tab)
    current_tab = current_tab || 'on_sale'
    class_name = tab_name == current_tab ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to t(".tabs.#{tab_name}"), "#{link_path}?current_tab=#{tab_name}"
    end
  end
end
