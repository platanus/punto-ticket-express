ActiveAdmin.register Producer do
  index do
    column :address
    column :contact_email
    column :contact_name
    column :name
    column :phone
    column :rut
    column :percent_fee
    column :fixed_fee
    bool_column :confirmed
    default_actions
  end

  filter :address

  show do
    attributes_table do
	    row :address
	    row :contact_email
	    row :contact_name
	    row :name
	    row :phone
	    row :rut
	    row :description
	    row :website
      row :percent_fee
      row :fixed_fee
      bool_row :confirmed
    end
  end
end
