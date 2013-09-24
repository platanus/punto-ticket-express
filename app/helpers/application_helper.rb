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

  def link_to_submit(text, css_class)
    link_to_function text, "$(':submit').trigger('click')", :class => css_class, :name => "publish"
  end

end
