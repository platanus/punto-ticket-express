# coding: utf-8
module EventDecorator
  def amounts_by_type ticket_type
    data = {name: ticket_type.name, tickets_count: 0, total: 0}
    query = ticket_type.tickets.completed
    data[:tickets_count] = query.count
    data[:total] = data[:tickets_count] * ticket_type.price
    data
  end

  def sold_amounts
    data = {count: 0, total: 0}
    query = tickets.completed
    data[:count] = query.count
    query = query.joins([:ticket_type])
    data[:total] = query.sum("ticket_types.price")
    data
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
