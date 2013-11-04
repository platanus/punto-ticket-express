class Event < ActiveRecord::Base
  attr_accessible :user_id, :address, :custom_url, :description, :name, :producer_id,
  :ticket_types_attributes, :is_published, :start_time, :end_time, :data_to_collect,
  :logo, :theme, :fixed_fee, :percent_fee, :include_fee

  # paperclip
  has_attached_file :logo, :styles => { :medium => "160x160>", :thumb => "100x100>" }

  # Saves required fields with the following format
  #  [{:name => :attr1, :required => false}, {:name => :attr2, :required => true}]
  # Possible attribute values are defined on NestedResource::NESTABLE_ATTRIBUTES constant
  serialize :data_to_collect, Array

  validates_presence_of :address, :description, :name
  validate :remains_published?
  validate :is_theme_type_valid?
  validates_attachment_content_type :logo, :content_type => /image/
  validates :percent_fee, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :fixed_fee, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  before_destroy :can_destroy?
  before_create :set_fee_values

  belongs_to :user
  belongs_to :producer
  has_many :ticket_types, dependent: :destroy
  has_many :tickets, through: :ticket_types
  has_many :promotions, as: :promotable
  has_many :users, through: :tickets
  has_many :transactions, through: :tickets, uniq: true

  accepts_nested_attributes_for :ticket_types, allow_destroy: true

  scope :published, where(is_published: true)

  delegate :name, to: :producer, prefix: true, allow_nil: true
  delegate :description, to: :producer, prefix: true, allow_nil: true
  delegate :fixed_fee, to: :producer, prefix: true, allow_nil: true
  delegate :percent_fee, to: :producer, prefix: true, allow_nil: true

  after_initialize :set_default_theme

  # Overrides data_to_collect method to convert the values param:
  # {"0"=>{"name"=>"name", "value"=>"none"}, "1"=>{"name"=>"last_name", "value"=>"optional"},
  # "2"=>{"name"=>"email", "value"=>"none"}, "3"=>{"name"=>"rut", "value"=>"optional"},
  # "4"=>{"name"=>"phone", "value"=>"none"}, "5"=>{"name"=>"mobile_phone", "value"=>"optional"},
  # "6"=>{"name"=>"address", "value"=>"none"}, "7"=>{"name"=>"company", "value"=>"required"},
  # "8"=>{"name"=>"job", "value"=>"required"}, "9"=>{"name"=>"job_address", "value"=>"none"},
  # "10"=>{"name"=>"job_phone", "value"=>"none"}, "11"=>{"name"=>"website", "value"=>"none"},
  # "12"=>{"name"=>"gender", "value"=>"optional"}, "13"=>{"name"=>"birthday", "value"=>"none"},
  # "14"=>{"name"=>"age", "value"=>"none"}}
  #
  # into:
  # [{:name=>"last_name", :required=>false},
  # {:name=>"rut", :required=>false}, {:name=>"mobile_phone", :required=>false},
  # {:name=>"company", :required=>true}, {:name=>"job", :required=>true},
  # {:name=>"gender", :required=>false}]
  #
  # @param values [Array]
  def data_to_collect=(values)
    result = []

    values.each do |item|
      item = item.last
      value = item["value"].to_sym
      next if value == :none
      result << {:name => item["name"], :required => (value == :required)}
    end

    # overwrite the attribute writer
    write_attribute(:data_to_collect, result)
  end

  # Returns saved attributes if each saved attribute matches with
  # an attribute defined on NestedResource class.
  # Returned array will be something like this:
  # [{:name => :attr1, :required => false}, {:name => :attr2, :required => true}]
  #
  # @return [Array]
  def nested_attributes
    return [] unless self.data_to_collect
    attributes = []
    NestedResource.nested_attributes.each do |col|
      self.data_to_collect.each do |attr|
        if col[:attr].to_s == attr[:name]
          attributes << col.merge({required: attr[:required]})
        end
      end
    end
    attributes
  end

  # Wrapper to get required nested attributes only
  #
  # @return [Array]
  def required_nested_attributes
    nested_attributes_to_a true
  end

  # Wrapper to get optional nested attributes only
  #
  # @return [Array]
  def optional_nested_attributes
    nested_attributes_to_a false
  end

  # Parses nested_attributes hash array and returns simple array with attribute names
  # It transforms this:
  # [{:attr=>:last_name, :type=>:string, :required=>false},
  # {:attr=>:rut, :type=>:string, :required=>false}, {:attr=>:mobile_phone, :type=>:string, :required=>false},
  # {:attr=>:company, :type=>:string, :required=>true}, {:attr=>:job, :type=>:string, :required=>true},
  # {:attr=>:gender, :type=>:boolean, :required=>false}]
  #
  # into this:
  # [:last_name, :rut, :mobile_phone, :company, :job, :gender]
  #
  # If required params is setted in true will return required values only. False for  optional values. Nil for all.
  #
  # @param required [Boolean]
  # @return [Array]
  def nested_attributes_to_a required = nil
    values = []
    self.nested_attributes.each do |na|
      if required.nil? or
        (required == true and na[:required] == true) or
        (required == false and na[:required] == false)
        values << na[:attr]
      end
    end
    values
  end

  # Gets promotions applied to all ticket types (event's promotions)
  # and promotions applied to each ticket type
  #
  # @return [Array]
  def all_promotions
    result = []
    result += self.promotions
    self.ticket_types.each { |tt| result += tt.promotions }
    result.sort_by { |promo| promo[:created_at] }.reverse!
  end

  def sold_amount
    query = self.tickets.completed
    query = query.joins([:ticket_type])
    query.sum("ticket_types.price")
  end

  def sold_tickets_count
    self.tickets.completed.count
  end

  def calculated_fixed_fee
    (self.sold_tickets_count.to_d * self.fixed_fee.to_d) rescue 0.0
  end

  def calculated_percent_fee
    (self.sold_amount.to_d * self.percent_fee.to_d / 100.0) rescue 0.0
  end

  private
    def remains_published?
      if !self.new_record? and self.is_published_was and
        (self.is_published_was != self.is_published)
        errors.add(:is_published, :published_event_cant_be_unpublished)
        return false
      end
    end

    def can_destroy?
      unless self.tickets.count.zero?
        errors.add(:base, :has_related_tickets)
        return false
      end
    end

    def set_default_theme
      self.theme ||= PTE::Theme::default
    end

    def set_fee_values
      self.fixed_fee = self.producer_fixed_fee unless self.fixed_fee
      self.percent_fee = self.producer_percent_fee unless self.percent_fee
    end

    def is_theme_type_valid?
      unless PTE::Theme::is_valid? self.theme
        self.errors.add(:theme, :invalid_theme_type)
        return false
      end
    end

end
