class EventsPresenter

	def self.totals_by_ticket_type event
		total = 0
		result = event.ticket_types.inject([]) do |result, ticket_type|
			type_data = {name: ticket_type.name, tickets_count: 0, total: 0}
			query = event.tickets
			query = query.joins([:transaction])
			query = query.where(["tickets.ticket_type_id = ?", ticket_type.id])
			query = query.where(["transactions.payment_status = ?", PTE::PaymentStatus.completed])
			type_data[:tickets_count] = query.count
			type_data[:total] = type_data[:tickets_count] * ticket_type.price
			total += type_data[:total]
			result << type_data
		end
		{total: total, data: result}
	end
end
