module PTE
  class PaymentStatus
    STATUSES = [:processing, :completed, :inactive]

    PTE::PaymentStatus::STATUSES.each do |status_name|
      self.class.class_eval do
        define_method(status_name) do 
          status_name
        end

        define_method("human_#{status_name}".to_sym) do 
          I18n.t("pte.payment_status.#{status_name}")
        end
      end
    end
  end
end
