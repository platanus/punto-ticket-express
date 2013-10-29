ActiveAdmin.register Event do
  index do
    column :name
    column :address
    column :custom_url
    bool_column :is_published
    column :created_at
    default_actions
  end

  filter :name
  filter :address
  filter :start
  filter :is_published

  show do
    attributes_table do
      row :name
      row :address
      row :description
      row :custom_url
      row :fixed_fee
      row :percent_fee do |a|
        "#{a.percent_fee}%"
      end
      bool_row :is_published
      row :total_fee do |a|
        number_to_currency a.calculated_fixed_fee + a.calculated_percent_fee
      end
    end
  end
end
