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

  def participants
    columns = self.participants_table_header
    transactions_with_resources = self.transactions.completed.joins([:nested_resource])
    tickets_with_resources = self.tickets.completed.joins([:nested_resource])
    nestable_objects = transactions_with_resources + tickets_with_resources

    nestable_objects.inject([]) { |result, nestable|
      nr = nestable.nested_resource
      row = columns.inject([]) { |data, attr| data << get_attr_value(nr, attr) }
      row << get_resource_show_path(nestable)
      result << row
    }.paginate(:page => params[:page], :per_page => 15)
  end

  def get_attr_value nested_resource, attr
    value = nested_resource[attr]

    if attr == :gender
      return I18n.t("gender.man") if value
      return I18n.t("gender.woman")
    end

    value
  end

  def get_resource_show_path nestable
    if nestable.kind_of? Transaction
      return puntopagos_transaction_nested_resource_path(nestable.id)

    elsif nestable.kind_of? Ticket
      return ticket_nested_resource_path(nestable.id)
    end

    return "#"
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
