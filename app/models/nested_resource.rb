class NestedResource < ActiveRecord::Base
  # attrs
  attr_accessible :address, :age, :birthday,
   :company, :email, :gender, :job, :job_address,
   :job_phone, :last_name, :mobile_phone, :name,
   :nestable_id, :nestable_type, :phone, :rut, :website

  attr_accessor :attributes_to_check

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

  module Gender
    WOMAN = 0
    MAN = 1
  end

  # validations
  NESTABLE_ATTRIBUTES.each do |attr|
    validates attr, presence: true, if: Proc.new { |nr| nr.attr_need_validation? attr }
  end

  validates :website,
    format: { with: %r{\Ahttps?:\/\/([^\s:@]+:[^\s:@]*@)?[A-Za-z\d\-]+(\.[A-Za-z\d\-]+)+\.?(:\d{1,5})?([\/?]\S*)?\z}i,
    message: I18n.t("activerecord.errors.messages.invalid_url") },
    allow_nil: true, allow_blank: true

  validates :age, numericality: { greater_than: 0 }

  validates :email,
    email_format: {message: I18n.t("activerecord.errors.messages.invalid_email"),
    allow_nil: true, allow_blank: true}

  validate :validate_birthdate
  validate :validate_gender
  validate :validate_rut

  def validate_gender
    return true unless self.gender
    unless self.gender == Gender::WOMAN or self.gender == Gender::MAN
      errors.add(:gender, :invalid_gender)
      return false
    end

    return true
  end

  def validate_birthdate
    return true unless self.birthday

    if self.birthday.to_datetime.year < 1900
      errors.add(:birthday, :invalid_date)
      return false
    end

    if self.birthday.to_datetime > Time.now
      errors.add(:birthday, :birth_date_greater_than_today)
      return false
    end

    return true
  end

  #Validating rut using Module 11 algorithm
  def validate_rut
    return true unless self.rut

    self.rut = self.rut.to_s.gsub(".", "")

    if self.rut.to_s.match(/^(|\d{1,8}-(\d{1}|K|k))$/).nil?
      errors.add(field, :invalid_rut_format)
      return false
    end

    number_verif_digit = self.rut.to_s.gsub(".", "").split("-")

    if number_verif_digit.size != 2
      errors.add(field, :invalid_rut_format)
      return false
    end

    number = number_verif_digit.first
    digit = number_verif_digit.last
    digit = 10 if number_verif_digit.last.downcase == "k"

    serie = [2,3,4,5,6,7]
    sum = 0

    number.split("").reverse.each_with_index do |n, i|
      serie_value = serie[i]
      serie_value = serie[i - serie.size] if serie_value.nil?
      sum += n.to_i * serie_value
    end

    result = 11 - (sum % 11)
    result = 0 if result == 11

    if result != digit.to_i
      errors.add(field, :invalid_verification_digit)
      return false
    end

    return true
  end

  def attr_need_validation attr
    return false attributes_to_check.nil?
    attributes_to_check.each do |attr|
      if attr[:name].to_sym == attr.to_sym and attr[:required]
        return true
      end
    end
    return false
  end

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
