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
end
