module TicketsHelper
  def printable_ticket_label label, value
    haml_tag :div, class: "printable-label-wrapper" do
      haml_tag :div, label.capitalize, class: "printable-label"
      haml_tag :div, value.capitalize, class: "printable-value"
    end
  end
end
