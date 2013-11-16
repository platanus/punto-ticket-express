module Puntopagos::TransactionsHelper

	def calculate_price ticket_type
		ticket_type['price'].to_i * ticket_type['qty'].to_i
	end

	def payment_label payment_status
  	content_tag(:span, t("pte.payment_status.#{payment_status}"),
    	class: "#{payment_status}-payment-status")
	end

  def payment_button form
    form.button(I18n.t("buttons.pay_puntopagos"),
      :class => "btn btn-large btn-success btn-total")
  end

  def ticket_types_to_params ticket_types
    result = {}
    ticket_types.each_with_index do |tt, idx|
      result[idx.to_s] = {:id => tt.id, :qty => tt.bought_quantity}
    end
    result.to_json
  end

  def payment_methods
    types = []

    if Rails.env == 'production'
      types << ['Santander Rio', 1]
      types << ['Tarjeta Presto', 2]
      types << ['Transbank', 3]
      types << ['Banco de Chile', 4]
      types << ['BCI', 5]
      types << ['TBanc', 6]
      types << ['Banco Estado', 7]
      types << ['Ripley', 10]
      types << ['Paypal', 15]
    else
      types << ['Presto', 2]
      types << ['WebPay', 3]
      types << ['Ripley', 10]
      types << ['BBVA', 16]
      #types << ['Cencosud', 17]
      #types << ['Paris', 18]
      #types << ['Jumbo', 19]
      #types << ['Easy', 20]
    end
  end
end
