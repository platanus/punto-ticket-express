class NestedResource < ActiveRecord::Base
  # attrs
  attr_accessible :address, :age, :birthday, :company, :email, :gender, :job, :job_address, :job_phone, :last_name, :mobile_phone, :name, :nestable_id, :nestable_type, :phone, :rut, :website

  # relationship
  belongs_to :nestable, polymorphic: true
end
