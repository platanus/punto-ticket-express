module ApplicationHelper
  def current_user_email
    return @current_user_email if @current_user_email
    @current_user_email =  User.find_by_id(current_user.id).email
  end

  def nav_link(link_text, link_path)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end
end
