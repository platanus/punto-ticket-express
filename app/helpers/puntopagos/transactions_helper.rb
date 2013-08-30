module Puntopagos::TransactionsHelper
	def calculate_price ticket_type
		ticket_type['price'].to_i * ticket_type['qty'].to_i
	end

	def calculate_total ticket_types
		ticket_types.inject(0) {|sum, hash| sum + (hash['price'].to_i * hash['qty'].to_i) }
	end
end
