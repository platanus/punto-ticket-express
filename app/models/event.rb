class Event < ActiveRecord::Base
  include PTE::RowStatus

  attr_accessible :user_id, :address, :custom_url, :description, :name, :producer_id,
  :ticket_types_attributes, :is_published, :start_time, :end_time, :data_to_collect,
  :logo, :theme, :fixed_fee, :percent_fee, :include_fee, :nested_resource_source,
  :sell_limit, :enclosure, :status

  # paperclip
  has_attached_file :logo, :styles => { :medium => "160x160>", :thumb => "100x100>" }

  # Saves required fields with the following format
  #  [{:name => :attr1, :required => false}, {:name => :attr2, :required => true}]
  # Possible attribute values are defined on NestedResource::NESTABLE_ATTRIBUTES constant
  serialize :data_to_collect, Array

  before_create :set_fee_values
  before_update :set_fee_if_producer_change

  belongs_to :user
  belongs_to :producer
  has_many :ticket_types, dependent: :destroy
  has_many :tickets, through: :ticket_types
  has_many :promotions, as: :promotable
  has_many :users, through: :tickets
  has_many :transactions, through: :tickets, uniq: true

  validates_presence_of :address, :description, :name, :producer, :user,
    :start_time, :end_time, :publish_start_time, :publish_end_time
  validates :start_time, date: { after_or_equal_to: Proc.new { DateTime.now }, message: :date_greater_than_today }
  validates :end_time, date: true
  validate :dates_range_valid?
  validates :publish_start_time, date: true
  validates :publish_end_time, date: true
  validate :publish_dates_range_valid?
  validate :publish_dates_range_inside_event_dates_range?
  validate :is_theme_type_valid?
  validates_attachment_content_type :logo, :content_type => /image/
  validates :percent_fee, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :fixed_fee, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  accepts_nested_attributes_for :ticket_types, allow_destroy: true

  scope :published, where(is_published: true)
  scope :draft, where("is_published = false OR is_published IS NULL")
  scope :expired,  where('end_time <= ?', DateTime.now)
  scope :not_expired, where('end_time >= ?', DateTime.now)
  scope :in_publish_range, where('publish_start_time <= ? AND publish_end_time >= ?', DateTime.now, DateTime.now)

  default_scope active

  delegate :name, to: :producer, prefix: true, allow_nil: true
  delegate :confirmed, to: :producer, prefix: true, allow_nil: true
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

  def require_transaction_resource?
    !self.nested_attributes.empty? and
    (self.nested_resource_source == PTE::NestedResourceSource.all or
    self.nested_resource_source == PTE::NestedResourceSource.transaction)
  end

  def require_ticket_resources?
    !self.nested_attributes.empty? and
    (self.nested_resource_source == PTE::NestedResourceSource.all or
    self.nested_resource_source == PTE::NestedResourceSource.tickets)
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

  # Gets event total amount from tickets with completed payment status
  #
  # @return [Decimal]
  def sold_amount
    query = self.tickets.completed
    query = query.joins([:ticket_type])
    query.sum("ticket_types.price").to_d
  end

  def discount_amount
    # TODO:
    # Save discount on ticket field.
    # Do calculations every time will not work well with many tickets
    self.tickets.completed.inject(0.0) do |total, ticket|
      total += ticket.discount
    end
  end

  # Returns true if this today is in publication dates range.
  #
  # @return [Boolean]
  def in_publish_range?
    return false if !publish_start_time or !publish_end_time
    (publish_start_time <= DateTime.now && publish_end_time >= DateTime.now)
  end

  def is_past_event?
    return false unless self.start_time
    self.start_time <= DateTime.now
  end

  def publish
    self.update_attributes({is_published: true})
  end

  def unpublish
    self.update_attributes({is_published: false})
  end

  def available_tickets_count
    self.ticket_types.inject(0){ |count, tt| count += tt.available_tickets_count }
  end

  def sold_tickets_count
    self.tickets.completed.count
  end

  def total_fee
    (self.calculated_fixed_fee + calculated_percent_fee) rescue 0.0
  end

  def raised_amount
    self.sold_amount - self.total_fee - self.discount_amount
  end

  def calculated_fixed_fee
    (self.sold_tickets_count.to_d * self.fixed_fee.to_d) rescue 0.0
  end

  def calculated_percent_fee
    (self.sold_amount.to_d * self.percent_fee.to_d / 100.0) rescue 0.0
  end

  def can_destroy?
    return true if self.tickets.count.zero?
    errors.add(:base, :has_related_tickets)
    return false
  end

  def disable_or_destroy
    if self.can_destroy?
      self.destroy
    else
      self.update_column :status, PTE::RowStatus::ROW_DELETED
    end
  end

  # ActiveRelation objects
  def self.on_sale
    self.not_expired.published
  end

  def self.ended
    self.expired.published
  end

  private
    def set_default_theme
      self.theme ||= PTE::Theme::default
    end

    def set_fee_if_producer_change
      if self.producer_id_was != self.producer_id
        self.fixed_fee = self.producer_fixed_fee
        self.percent_fee = self.producer_percent_fee
      end
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

    def dates_range_valid?
      if start_time.nil? or end_time.nil? or
        end_time < start_time
        errors.add(:end_time, :end_date_lower_than_start_date)
      end
    end

    def publish_dates_range_valid?
      if publish_start_time.nil? or publish_end_time.nil? or
        publish_end_time < publish_start_time
        errors.add(:publish_end_time, :end_date_lower_than_start_date)
      end
    end

    def publish_dates_range_inside_event_dates_range?
      if start_time.nil? or end_time.nil? or
        publish_start_time.nil? or publish_end_time.nil? or
        (publish_start_time < start_time) or (publish_end_time > end_time)
        errors.add(:publish_start_time, :publish_dates_out_of_event_dates_range)
        errors.add(:publish_end_time, :publish_dates_out_of_event_dates_range)
      end
    end
end
