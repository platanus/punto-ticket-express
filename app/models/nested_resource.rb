class NestedResource < ActiveRecord::Base
  attr_accessible :address, :age, :birthday,
   :company, :email, :gender, :job, :job_address,
   :job_phone, :last_name, :mobile_phone, :name,
   :nestable_id, :nestable_type, :phone, :rut, :website

  # Defines which attibutes are required in a particular NestedResource instance.
  # The format must be like this shown below:
  #  [:attr1, :attr2, :attr3]
  # Possible attribute values are defined on NESTABLE_ATTRIBUTES constant
  attr_accessor :required_attributes
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

  validates :website,
    format: { with: %r{\Ahttps?:\/\/([^\s:@]+:[^\s:@]*@)?[A-Za-z\d\-]+(\.[A-Za-z\d\-]+)+\.?(:\d{1,5})?([\/?]\S*)?\z}i,
    message: I18n.t("activerecord.errors.messages.invalid_url") },
    allow_nil: true, allow_blank: true

  validates :age, numericality: { greater_than: 0 }, allow_nil: true

  validates :email,
    email_format: {message: I18n.t("activerecord.errors.messages.invalid_email"),
    allow_nil: true, allow_blank: true}

  validate :validate_birthdate
  validate :validate_gender
  validate :validate_rut
  validate :validate_required_fields

  def validate_required_fields
    NESTABLE_ATTRIBUTES.each do |attr|
      if self.attr_need_validation?(attr) and self[attr].to_s.blank?
        errors.add(attr, :blank)
      end
    end
  end

  def validate_gender
    return true if self.gender.to_s.blank?

    unless self.gender == false or self.gender == true
      errors.add(:gender, :invalid_gender)
      return false
    end

    return true
  end

  def validate_birthdate
    return true if self.birthday.to_s.blank?

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

  #Validates RUT using Module 11 algorithm
  def validate_rut
    return true if self.rut.to_s.blank?

    self.rut = self.rut.to_s.gsub(".", "")

    if self.rut.to_s.match(/^(|\d{1,8}-(\d{1}|K|k))$/).nil?
      errors.add(:rut, :invalid_rut_format)
      return false
    end

    number_verif_digit = self.rut.to_s.gsub(".", "").split("-")

    if number_verif_digit.size != 2
      errors.add(:rut, :invalid_rut_format)
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
      errors.add(:rut, :invalid_verification_digit)
      return false
    end

    return true
  end

  # Verifies if attr is a required attribute, checking this param against each required attribute.
  # Required attributes are defined on required_attributes.
  #
  # @param attr [Symbol] can be any into NESTABLE_ATTRIBUTES constant
  # @return [Boolean]
  def attr_need_validation? attr
    return false unless required_attributes
    required_attributes.include?(attr)
  end

  # Returns all nestable attributes with the following structure:
  #  [{attr: :email, type: :string}, {attr: :gender, type: :boolean}]
  #
  # @return [Array]
  def self.nested_attributes
    result = []

    self.columns.each do |column|
      attr_name = column.name.to_sym
      next unless NESTABLE_ATTRIBUTES.include? attr_name
      result << {attr: attr_name, type: column.type}
    end

    result
  end

  def self.genders_to_a
    [[I18n.t("gender.woman"), Gender::WOMAN],
    [I18n.t("gender.man"), Gender::MAN]]
  end

end
