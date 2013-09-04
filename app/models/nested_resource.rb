class NestedResource < ActiveRecord::Base
  # attrs
  attr_accessible :address, :age, :birthday,
   :company, :email, :gender, :job, :job_address,
   :job_phone, :last_name, :mobile_phone, :name,
   :nestable_id, :nestable_type, :phone, :rut, :website

  # relationship
  belongs_to :nestable, polymorphic: true

  NESTABLE_ATTRIBUTES = [
    :address,
    :age,
    :birthday,
    :company,
    :email,
    :gender,
    :job,
    :job_address,
    :job_phone,
    :last_name,
    :mobile_phone,
    :name,
    :phone,
    :rut,
    :website
  ]

  def self.nested_attributes
    result = []

    self.columns.each do |column|
      attr_name = column.name.to_sym
      next unless NESTABLE_ATTRIBUTES.include? attr_name
      result << {attr: attr_name, type: column.type}
    end

    result
  end
end
