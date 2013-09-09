module ApplicationHelper
  def back_btn
    link_to t("buttons.back"), request.referrer, :class => 'btn'
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end
end
