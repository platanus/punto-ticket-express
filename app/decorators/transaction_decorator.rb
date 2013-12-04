# coding: utf-8
module TransactionDecorator
  def ticket_types_with_promotions ticket_types
    types = []

    ticket_types.each do |ticket_type|
      type = {
        id: ticket_type.id,
        name: I18n.t("puntopagos.transactions.transaction_summary.ticket_type_label",
          name: ticket_type.name, qty: ticket_type.bought_quantity,
          price: number_to_currency(ticket_type.price)),
        price: ticket_type.bought_quantity * ticket_type.price,
        quantity: ticket_type.quantity,
        bought_quantity: ticket_type.bought_quantity,
        promotions: [] }

      ticket_type.all_promotions.each do |promo|
        next unless promo.is_promo_available? and promo.enabled
        next unless promo.is_valid_for_qty?(ticket_type.bought_quantity)

        type[:promotions] << {
          name: I18n.t("puntopagos.transactions.transaction_summary.#{promo.promotion_type}_label",
            name: promo.name, value: number_with_delimiter(promo.promotion_type_config)),
          discount: (promo.discount(ticket_type.price) * ticket_type.bought_quantity),
          code: promo.hex_activation_code,
          normal_code: promo.activation_code,
          ticket_type_id: ticket_type.id,
          id: promo.id,
        }

        type[:promotions].sort_by!{ |promo| promo[:discount] }
      end

      types << type
    end

    types
  end

  # Returns transaction's data grouped by ticket type.
  # By type it returns tickets count, type price and count x price.
  # Response example:
  #  [{count: 3, type_name: "Vip", total: 600},
  #   {count: 2, type_name: "Campo", total: 200}]
  #
  # @return [Array]
  def tickets_data_by_type
    self.ticket_types.inject([]) do |result, ticket_type|
      tickets = self.tickets.where(["tickets.ticket_type_id = ?", ticket_type.id])
      total = tickets.inject(0) do |amount, ticket|
        amount += ticket.price_minus_discount
      end

      result << {
        type_name: ticket_type.name,
        count: tickets.count,
        total: total
      }
    end
  end
end
