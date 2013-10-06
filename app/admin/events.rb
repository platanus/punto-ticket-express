ActiveAdmin.register Event do
  index do
    column :name
    column :description
    column :address
    column :custom_url
    column :is_published
    column :created_at
    default_actions
  end
end
