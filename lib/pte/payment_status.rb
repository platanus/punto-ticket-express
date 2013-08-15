module PTE
  class PaymentStatus
    STATUSES = [:processing, :completed, :inactive]

    PTE::PaymentStatus::STATUSES.each do |status_name|
      self.class.class_eval do
        define_method(status_name) do 
          status_name.to_s
        end

        define_method("human_#{status_name}".to_sym) do 
          I18n.t("pte.payment_status.#{status_name}")
        end
      end
    end

    def self.is_valid? status_name
      return false if status_name.nil? or status_name.empty?
      PTE::PaymentStatus::STATUSES.include? status_name.to_sym
    end
  end
end
