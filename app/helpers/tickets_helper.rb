module TicketsHelper
  def printable_ticket_label label, value
    content_tag :div, class: "printable-label-wrapper row-fluid" do
      concat(content_tag :div, label.capitalize + ": ", class: "printable-label span2")
      concat(content_tag :div, value.capitalize, class: "printable-value span10")
    end
  end
end
