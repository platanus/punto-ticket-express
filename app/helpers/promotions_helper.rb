module PromotionsHelper

  def short_promo_type promo
    haml_tag :div, class: "promo-type #{promo.promotion_type.dasherize}" do
      haml_concat(I18n.t("pte.promo_type.#{promo.promotion_type}",
        value: number_with_delimiter(promo.promotion_type_config)))
    end
  end

  def enable_promo_link promo
    return unless promo.is_promo_available?
    label = promo.enabled ? "disable" : "enable"
    haml_tag(:div) do
      haml_concat(link_to(I18n.t("buttons.#{label}"),
        eval("#{label}_promotion_path(id: #{promo.id})"),
        method: :put))
    end
  end
end
