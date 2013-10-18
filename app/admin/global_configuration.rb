ActiveAdmin.register GlobalConfiguration do
  actions :show, :edit, :update

  show :title => I18n.t("activerecord.models.global_configuration.one") do
    attributes_table do
	    row :fixed_fee
	    row :percent_fee
    end
  end

  controller do
    def index
      redirect_to(admin_global_configuration_url(GlobalConfiguration.first))
    end
  end
end