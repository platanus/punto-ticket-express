module PTE
  class PaymentStatus
    STATUSES = [:processing, :completed, :inactive]

    PTE::PaymentStatus::STATUSES.each do |status_name|
      self.class.class_eval do
        define_method(status_name) do
          status_name.to_s
        end
      end
    end

    def self.human_name status_name
      I18n.t("pte.payment_status.#{status_name}", default: "Undefined status name" )
    end

    def self.is_valid? status_name
      return false if status_name.nil? or status_name.empty?
      PTE::PaymentStatus::STATUSES.include? status_name.to_sym
    end
  end
end
