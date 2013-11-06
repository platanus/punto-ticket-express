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
        next if promo.is_nx1? and (ticket_type.bought_quantity < promo.promotion_type_config.to_i)

        type[:promotions] << {
          name: I18n.t("puntopagos.transactions.transaction_summary.#{promo.promotion_type}_label",
            name: promo.name, value: number_with_delimiter(promo.promotion_type_config)),
          discount: promo.discount_by_quantity(ticket_type.bought_quantity, ticket_type.price),
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
end
