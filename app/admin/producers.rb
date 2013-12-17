ActiveAdmin.register Producer do

  before_update do |producer|
    @already_confirmed = producer.confirmed_was
  end

  after_update do |producer|
    return if producer.users.size.zero?
    if !@already_confirmed and producer.confirmed
      ProducerMailer.confirmed_producer(producer, producer.users.first).deliver
    end
  end

  index do
    column :logo do |producer|
      link_to(image_tag(producer.logo.url(:thumb), :height => '80'), admin_producer_path(producer))
    end
    column :address
    column :contact_email
    column :contact_name
    column :name
    column :phone
    column :rut
    bool_column :confirmed
    default_actions
  end

  filter :address

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Admin Details" do
      # f.input :logo, :as => :file, :hint => f.template.image_tag(f.object.logo.url(:medium))
      f.input :logo, :as => :file
      f.input :name
      f.input :rut
      f.input :address
      f.input :phone
      f.input :contact_name
      f.input :contact_email
      f.input :description
      f.input :website
      f.input :confirmed
      f.input :corporate_name
      f.input :brief
      f.input :fixed_fee
      f.input :percent_fee
    end
    f.actions
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
      row :percent_fee do |a|
        "#{a.percent_fee}%"
      end
      row :fixed_fee
      bool_row :confirmed
    end
  end
end
