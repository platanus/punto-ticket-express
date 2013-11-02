# coding: utf-8
module TransactionDecorator
  def ticket_types_with_promotions ticket_types
    types = []

    ticket_types.each do |ticket_type|
      type = { name: ticket_type.name,
        price: ticket_type.price,
        quantity: ticket_type.quantity,
        bought_quantity: ticket_type.quantity,
        promotions: [] }

      ticket_type.all_promotions.each do |promo|
        next unless promo.is_promo_available?
        next unless promo.enabled
        promo.load_discount(ticket_type.price)
        type[:promotions] << {
          name: promo.name,
          discount: promo.discount.to_i,
          code: promo.activation_code }

        type[:promotions].sort_by!{ |promo| promo[:discount] }
      end

      types << type
    end

    types
  end
end
