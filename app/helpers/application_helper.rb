module ApplicationHelper

  def flash_class(level)
    case level
    when :notice then "success"
    when :error then "error"
    when :alert then "warning"
    end
  end

  def current_user_identifier
    return @current_user_identifier if @current_user_identifier
    @current_user_identifier =  User.find_by_id(current_user.id).identifier
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def link_to_id(text, id, css_class)
    link_to_function text, "$('##{id}').trigger('click')",
      :class => css_class, :name => "publish"
  end

  def gender_label gender
    return I18n.t("gender.man") if gender == true
    return I18n.t("gender.woman") if gender == false
    return nil
  end

  def human_boolean value
    icon = value ? '&#x2714;'.html_safe : '&#x2717;'.html_safe
    content_tag(:div){ concat(icon) }
  end

  def line_through value
    return if value
    "line-through"
  end

  def errors_to_flash object
    return unless object.errors.any?
    html = errors_to_html(object).html_safe
    flash[:error] = html if html
  end

  def errors_to_html object
    return unless object.errors.any?
    content_tag(:div) do
      concat(content_tag(:h4, "Ocurrieron los siguientes errores:"))
      object.errors.keys.each do |attr|
        attr_label = "#{object.class.human_attribute_name(attr)}: "
        concat(content_tag(:p) do
         concat(content_tag(:strong, attr_label)) unless attr == :base
         concat(object.errors[attr].join(", "))
        end)
      end
    end
  end

  def facebook_like_button url
    url = "https://www.facebook.com/puntoticket" if url.to_s.empty?
    src = "//www.facebook.com/plugins/like.php?href=#{url}&amp;width&amp;layout=standard&amp;action=like&amp;show_faces=false&amp;share=true&amp;height=35"
    content_tag(:iframe, nil, src: src, scrolling: "no", frameborder: "0", style: "border:none; overflow:hidden; height:35px; width: 600px;", allowTransparency: "true")
  end
end
