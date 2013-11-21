# coding: utf-8
module EventDecorator
  def amounts_by_type ticket_type
    {name: ticket_type.name,
     count: ticket_type.sold_tickets_count,
     sub_total: ticket_type.sold_amount,
     fee: ticket_type.total_fee,
     discount: ticket_type.discount_amount,
     total: ticket_type.raised_amount}
  end

  def sold_amounts
    {count: self.sold_tickets_count,
     discount: self.discount_amount,
     sub_total: self.sold_amount,
     fee: self.total_fee,
     total: self.raised_amount}
  end

  # Returns first 4 attribute names of an event's nested resource. Prioritizing mandatory fields.
  # @return [Array] with PTE::PaymentStatus.processing as payment_status
  def participants_table_header
    (self.required_nested_attributes + self.optional_nested_attributes)[0..3]
  end

  def participants transactions
    columns = self.participants_table_header
    transactions.inject([]) do |result, transaction|
      nr = transaction.nested_resource
      row = columns.inject([]) do |data, attr|
        data << get_attr_value(nr, attr)
      end
      row << transaction.id
      result << row
    end
  end

  def get_attr_value nested_resource, attr
    value = nested_resource[attr]

    if attr == :gender
      return I18n.t("gender.man") if value
      return I18n.t("gender.woman")
    end

    value
  end

  def ticket_types_for_table
    self.ticket_types.inject([]) do |result, tt|
      result << {
        name: tt.name,
        id: tt.id,
        price: tt.price_minus_fee,
        stock: tt.available_tickets_count,
        promotion_price: tt.promotion_price,
        bought_quantity: 0 }
    end
  end
end
