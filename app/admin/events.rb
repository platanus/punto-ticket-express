ActiveAdmin.register Event do
  index do
    column :name
    column :description
    column :address
    column :organizer_name
    column :custom_url
    column :is_published
    column :created_at
    default_actions
  end
end
