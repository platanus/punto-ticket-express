module TicketsHelper
  def printable_ticket_label label, value
    haml_tag :div, class: "printable-label-wrapper row-fluid" do
      haml_tag :div, label.capitalize + ": ", class: "printable-label span2"
      haml_tag :div, value.capitalize, class: "printable-value span10"
    end
  end
end
