module PromotionsHelper

  def promo_types_for_select
    PTE::PromoType.types_to_a
  end

  def promo_scopes_for_select event
    event.ticket_types.map { |tt| [tt.name, tt.id] }
  end

  def short_promo_type promo
    haml_tag :div, class: "promo-type #{promo.promotion_type.dasherize}" do
      haml_concat(I18n.t("pte.promo_type.with_value.#{promo.promotion_type}",
        value: number_with_delimiter(promo.promotion_type_config)))
    end
  end

  def enable_promo_link promo
    label = promo.enabled ? "disable" : "enable"
    haml_tag(:div) do
      haml_concat(link_to(I18n.t("buttons.#{label}"),
        eval("#{label}_promotion_path(id: #{promo.id})"),
        method: :put))
    end
  end

  def promo_date_range_label promo
    if promo.start_date and promo.end_date
      return I18n.t("promotions.show.labels.dates_range",
        start: I18n.l(promo.start_date, format: :short),
        end: I18n.l(promo.end_date, format: :short))

    elsif promo.start_date
      return I18n.t("promotions.show.labels.start_date",
        date: I18n.l(promo.start_date, format: :short))

    elsif promo.end_date
      return I18n.t("promotions.show.labels.end_date",
        date: I18n.l(promo.end_date, format: :short))
    end

    I18n.t("promotions.show.labels.no_date")
  end

  def promo_limit_label promo
    return I18n.t("promotions.show.labels.no_limit") if promo.limit.to_s.empty?

    I18n.t("promotions.show.labels.limit",
      used: promo.sold_tickets.count.to_s, total: promo.limit.to_s)
  end

  def promo_code_label promo
    unless promo.activation_code.to_s.empty?
      return promo.activation_code
    end

    I18n.t("promotions.show.labels.activation_code")
  end

  def promo_enabled_for promo
    if promo.related_with_ticket_type?
      return I18n.t("promotions.show.labels.ticket_type_scope",
        ticket_type_name: promo.promotable.name)
    end

    I18n.t("promotions.show.labels.event_scope")
  end

  def promo_no_available_reasons promo
    return if promo.is_promo_available?

    haml_tag :div do
      haml_tag :label, I18n.t("promotions.show.labels.no_available_reasons")
      haml_tag :ul do
        haml_tag :li, I18n.t("promotions.show.labels.out_of_range") if promo.is_out_of_range?
        haml_tag :li, I18n.t("promotions.show.labels.limit_exceeded") if promo.is_limit_exceeded?
      end
    end
  end

  def render_promo_box promo
    haml_tag :div, class: "promo-type type-box #{promo.promotion_type.dasherize}" do
      haml_concat(I18n.t("pte.promo_type.with_value.#{promo.promotion_type}",
        value: number_with_delimiter(promo.promotion_type_config)))
    end
  end
end
