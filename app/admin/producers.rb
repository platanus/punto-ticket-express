ActiveAdmin.register Producer do
  index do
    column :address
    column :contact_email
    column :contact_name
    column :name
    column :phone
    column :rut
    bool_column :confirmed
    default_actions
  end

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
      bool_row :confirmed
    end
  end
end