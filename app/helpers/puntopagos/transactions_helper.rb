module Puntopagos::TransactionsHelper

	def calculate_price ticket_type
		ticket_type['price'].to_i * ticket_type['qty'].to_i
	end

	def calculate_total ticket_types
		ticket_types.inject(0) {|sum, hash| sum + (hash['price'].to_i * hash['qty'].to_i) }
	end

	def payment_label payment_status
  	content_tag(:span, t("pte.payment_status.#{payment_status}"),
    	class: "#{payment_status}-payment-status")
	end

	def build_tag f, name, type
		case type.to_s
		when 'string'
			return f.text_field name, :class => 'input-xlarge'
		when 'integer'
			return f.text_field name, :type => 'number', :class => 'input-xlarge'
		else
			return f.text_field name, :class => 'input-xlarge'
		end
	end

end
