module TicketTypesHelper
  def ticket_type_label ticket
    [ticket.ticket_type_name,
     ticket.ticket_type_price,
     ticket.quantity,
     ticket.total_price].join(", ")
  end
end