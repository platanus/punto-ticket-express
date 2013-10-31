module PTE
  class PromoType
    TYPES = [:percent_discount, :amount_discount, :nx1]

    PTE::PromoType::TYPES.each do |type_name|
      self.class.class_eval do
        define_method(type_name) do
          type_name.to_s
        end
      end
    end

    def self.human_name status_name
      I18n.t("pte.promo_type.#{status_name}", default: "Undefined promo type name" )
    end

    def self.is_valid? type_name
      return false if type_name.nil? or type_name.empty?
      PTE::PromoType::TYPES.include? type_name.to_sym
    end

    def self.types_to_a
      TYPES.map {|type| [human_name(type.to_s), type]}
    end
  end
end
