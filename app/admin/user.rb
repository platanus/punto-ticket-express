ActiveAdmin.register User do
  index do
    column :email
    column :name
    column :current_sign_in_at
    column :last_sign_in_at
    column :sign_in_count
    column :role, sortable: :role do |user|
      user.human_role
    end
    default_actions
  end

  filter :email
  filter :role, as: :select, collection: PTE::Role.types_to_a

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
      f.input :name
      f.input :role, as: :select, collection: PTE::Role.types_to_a
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  show do
    attributes_table do
      row :email
      row :name
      row :role do |user|
        user.human_role
      end
      row :last_sign_in_at
      row :created_at
      row :updated_at
    end
  end
end
