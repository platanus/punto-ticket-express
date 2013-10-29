# coding: utf-8
module EventDecorator
  def amounts_by_type ticket_type
    {name: ticket_type.name,
     tickets_count: ticket_type.sold_tickets_count,
     sub_total: ticket_type.sold_amount_before_fee,
     fixed_fee_total: ticket_type.fixed_fee,
     percent_fee_total: ticket_type.percent_fee,
     total: ticket_type.sold_amount}
  end

  def sold_amounts
    {count: self.sold_tickets_count, total: self.sold_amount}
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
end
