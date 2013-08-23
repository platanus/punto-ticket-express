module TicketTypesHelper
  def ticket_type_label ticket
    printable_ticket_label(TicketType.model_name.human,
      t("tickets.show.total_price_label",
      ticket_type: ticket.ticket_type_name,
      price: ticket.ticket_type_price))
  end
end