module ApplicationHelper
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
    haml_tag(:div) do
      haml_concat(icon)
    end
  end

  def line_through value
    return if value
    "line-through"
  end
end
