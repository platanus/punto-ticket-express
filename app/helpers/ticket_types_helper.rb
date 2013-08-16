module TicketTypesHelper
  def ticket_type_label ticket
    printable_ticket_label(TicketType.model_name.human, complete_ticket_price(ticket))
  end

  def complete_ticket_price ticket
    value = t("tickets.show.total_price_label",
      ticket_type: ticket.ticket_type_name,
      quantity: ticket.quantity,
      price: ticket.ticket_type_price,
      total_price: ticket.total_price)
  end
end