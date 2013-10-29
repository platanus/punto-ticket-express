ActiveAdmin.register GlobalConfiguration do
  actions :show, :edit, :update

  show :title => GlobalConfiguration.config.display_name do
    attributes_table do
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
