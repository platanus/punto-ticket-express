ActiveAdmin.register GlobalConfiguration do
  actions :show, :edit, :update

  show :title => I18n.t("activerecord.models.global_configuration.one") do
    attributes_table do
      row :sell_limit
	    row :fixed_fee
	    row :percent_fee do |a|
        "#{a.percent_fee}%"
      end
    end
  end

  controller do
    def index
      redirect_to(admin_global_configuration_url(GlobalConfiguration.config))
    end
  end
end
