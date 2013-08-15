module TicketTypesHelper
  def ticket_type_label ticket
    value = t(".total_price_label",
      ticket_type: ticket.ticket_type_name,
      quantity: ticket.quantity,
      price: ticket.ticket_type_price,
      total_price: ticket.total_price)
    printable_ticket_label(TicketType.model_name.human, value)
  end
end