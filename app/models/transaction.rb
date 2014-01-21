class Transaction < ActiveRecord::Base
  attr_accessible :amount, :details, :payment_status, :token, :transaction_time, :user_id, :nested_resource_attributes, :error
  attr_accessor :payment_method, :tickets_nested_resources

  belongs_to :user
  has_many :tickets
  has_many :ticket_types, through: :tickets, uniq: true
  has_many :promotions, through: :tickets, uniq: true
  has_many :events, through: :ticket_types, uniq: true
  has_one :nested_resource, as: :nestable

  accepts_nested_attributes_for :nested_resource

  scope :processing, where(["payment_status = ?", PTE::PaymentStatus.processing])
  scope :completed, where(["payment_status = ?", PTE::PaymentStatus.completed])
  scope :more_than_x_minutes_old, lambda {|x| where(["created_at <= ?", Time.now - x.minutes])}

  delegate :email, to: :user, prefix: true, allow_nil: true
  delegate :name, to: :user, prefix: true, allow_nil: true
  delegate :identifier, to: :user, prefix: true, allow_nil: true

  def event
    events.first
  end

  def event_name
    event.try(:name)
  end

  def event_nested_attributes
    event.try(:nested_attributes)
  end

  def event_start_time
    event.try(:start_time)
  end

  def event_end_time
    event.try(:end_time)
  end

  # Starts a transaction.
  # Creates tickets based on ticket_types.
  #
  # @param user_id [integer]
  # @param ticket_types [Array] TicketTypes collection with
  #  bought_quantity setted with an positive integer.
  # @param optional_data [Hash] can have the following keys:
  #  - transaction_nested_resource (to relate a NestedResource with the new transaction).
  #    Structure example: {attr1: 'value1', attr2: 'value1', attr3: 'value3'}
  #  - tickets_nested_resources (to relate a NestedResource for each transaction ticket).
  #  - promotions (Promotions collection to apply on tickets)
  #    Structure example: [{:ticket_type_id=>1, :promotion=>#<Promotion>}, {:ticket_type_id=>2, :promotion=>#<Promotion>}]
  # @return [Transaction] with PTE::PaymentStatus.processing as payment_status

  def self.begin user_id, ticket_types, optional_data = nil
    begin
      transaction = Transaction.new

      ActiveRecord::Base.transaction do
        optional_data = {} unless optional_data
        transaction.prepare_tickets_nested_resources(
          optional_data[:tickets_nested_resources])
        validate_user_existance(user_id)
        validate_ticket_types(ticket_types)
        transaction_event = ticket_types.first.event
        #load resource BEFORE save_beginning_status
        #AFTER, ActiveRecord::RecordNotSaved will be dispached
        transaction.load_nested_resource(transaction_event,
          optional_data[:transaction_nested_resource])
        transaction.save_beginning_status(user_id)
        transaction.load_tickets(transaction_event, ticket_types)
        transaction.apply_promotions(optional_data[:promotions])
        transaction.load_ticket_nested_resources(transaction_event)

        raise ActiveRecord::Rollback if transaction.errors.any?
      end
      transaction

    rescue Exception => e
      get_transaction_with_error(e.message)
    end
  end

  # Ends a transaction.
  # If this method is executed sucessfully, the transaction will be
  # returned with payment_status value as PTE::PaymentStatus.completed
  #
  # @param token [Strin]
  # @return [Transaction]
  def self.complete token
    transaction = Transaction.find_by_token token
    return nil unless transaction
    transaction.save_finished_status
    transaction
  end

  # Cancels a transaction.
  # If this method is executed sucessfully, the transaction will be
  # returned with payment_status value as PTE::PaymentStatus.inactive
  #
  # @param token [Strin]
  # @return [Transaction]
  def self.cancel token, error
    transaction = Transaction.find_by_token token
    return Transaction.new(error: 'transaction not found using given token') unless transaction
    transaction.error = error
    transaction.payment_status = PTE::PaymentStatus.inactive
    transaction.save(validate: false)
  end

  # Gets new Transaction instance with error attr filled with error_msg param
  #
  # @param error_msg [String]
  # @return [Transaction]
  def self.get_transaction_with_error error_msg
    log_error(error_msg)
    transaction = Transaction.new
    transaction.error = error_msg
    transaction.errors.add(:base, :unknown_error)
    transaction
  end

  # Returns true when transaction has expected errors like
  # "no tickets left", or "errors on nested resources".
  #
  # @return [Boolean]
  def with_errors?
    self.errors.any?
  end

  # Returns true when irrecoverable errors occurs
  #
  # @return [Boolean]
  def with_irrecoverable_errors?
    !self.error.nil?
  end

  # Loads NestedResource instance into transaction
  # @param [Hash] The structure of nested_resource_data param must be:
  #  {attr1: 'value1', attr2: 'value1', attr3: 'value3'}
  def load_nested_resource transaction_event, nested_resource_data
    begin
      return unless nested_resource_data
      nr = NestedResource.new(nested_resource_data)
      nr.required_attributes = transaction_event.required_nested_attributes
      self.nested_resource = nr
    rescue
      Transaction.raise_error("Invalid nested_resource_data structure given")
    end
  end

  # Loads tickets_nested_resources attr transforming nested_resource_data param
  # with this example structure:
  #
  #  [{:ticket_type_id=>"2",
  #    :resources=>[
  #      {"name"=>"Name participant 1", "last_name"=>"Last Name participant 1"},
  #      {"name"=>"Name participant 2", "last_name"=>""}]
  #   },{:ticket_type_id=>"3",
  #    :resources=>[
  #      {"name"=>"Name participant 3", "last_name"=>"Last Name participant 3"},
  #      {"name"=>"Name participant 4", "last_name"=>""}]
  #  }]
  #
  # into this:
  #
  #  [{:ticket_type_id=>"2",
  #    :resources=>[
  #      {:resource=>{"name"=>"Name participant 1", "last_name"=>"Last Name participant 1"},
  #       :errors=>{}},
  #      {:resource=>{"name"=>"Name participant 2", "last_name"=>""},
  #      :errors=>{}}]
  #  },{:ticket_type_id=>"3",
  #    :resources=>[
  #      {:resource=>{"name"=>"Name participant 3", "last_name"=>"Last Name participant 3"},
  #      :errors=>{}},
  #      {:resource=>{"name"=>"Name participant 4", "last_name"=>""},
  #      :errors=>{}}]
  #  }]
  #
  # @param nested_resource_data [Array]
  def prepare_tickets_nested_resources nested_resource_data
    begin
      self.tickets_nested_resources = []

      if nested_resource_data
        nested_resource_data.each do |tt|
          format_resources = []
          tt[:resources].each do |resource|
            format_resources << {resource: resource, errors: {}}
          end
          tt[:resources] = format_resources
        end

        self.tickets_nested_resources = nested_resource_data
      end
    rescue
      Transaction.raise_error("Problem triyng to prepare tickets nested resources")
    end
  end

  # Relates tickets with resources_data in tickets_nested_resources attr
  # If a nested resource has errors, these will be loaded on errors attr of that resource.
  # For example:
  # {:ticket_type_id=>"2",
  #  :resources=>[
  #    {:resource=>{"name"=>"", "last_name"=>"Last Name participant 1"},
  #     :errors=>{:name=>["no puede estar en blanco"]}}
  #
  # @param transaction_event [Event]
  def load_ticket_nested_resources transaction_event
    begin
      errors_found = 0
      tickets_nested_resources.each do |tt|
        type_tickets = ticket_type_tickets tt[:ticket_type_id]
        type_tickets.each_with_index do |ticket, idx|
          nr = NestedResource.new(tt[:resources][idx][:resource])
          nr.required_attributes = transaction_event.required_nested_attributes

          if nr.valid?
            ticket.nested_resource = nr
          else
            errors_found += 1
            tt[:resources][idx][:errors] = nr.errors.messages
          end
        end
      end

      unless errors_found.zero?
        self.errors.add(:base, I18n.t('activerecord.errors.models.transaction.ticket_nested_resource_error'))
      end
    rescue
      Transaction.raise_error("Problem saving ticket_nested_resources")
    end
  end

  # Calculates the total amount of the transaction based on ticket prices
  #
  # @return [Fixnum]
  def total_amount
    self.tickets.inject(0) do |amount, ticket|
      amount += ticket.price_minus_discount
    end
  end

  # Returns total amount with two mandatory decimal values
  #
  # @return [String]
  def total_amount_to_s
    "%0.2f" % total_amount
  end

  def tickets_quantity
    tickets.count
  end

  # A transaction can be finished if has PTE::PaymentStatus.processing payment status only.
  #
  # @return [Boolean]
  def can_finish?
    self.payment_status == PTE::PaymentStatus.processing
  end

  # Saves the initial status of a transaction.
  # Transactions must start with an user and payment_status PTE::PaymentStatus.processing
  #
  # @return [Boolean]
  def save_beginning_status user_id
    self.payment_status = PTE::PaymentStatus.processing
    self.user_id = user_id
    self.transaction_time = Time.now
    self.save
  end

  # @return [Boolean]
  def save_finished_status
    self.update_attribute(:payment_status, PTE::PaymentStatus.completed)
  end

  # @return [Boolean]
  def save_inactive_status
    self.update_attribute(:payment_status, PTE::PaymentStatus.inactive)
  end

  # Applies a single promotion to tickets of each ticket type given
  #
  # @param data [Array] with structure:
  # [{:ticket_type_id=>1, :promotion=>#<Promotion>},
  # {:ticket_type_id=>2, :promotion=>#<Promotion>}]
  def apply_promotions data
    begin
      return unless data

      data.each do |item|
        type_tickets = self.ticket_type_tickets(item[:ticket_type_id])

        unless item[:promotion].apply(type_tickets)
          self.errors.add(:base, I18n.t("activerecord.errors.models.transaction.promotion_error"))
        end
      end
    rescue
      Transaction.raise_error("Problem applying promotions")
    end
  end

  # Returns tickets for this transaction for the given ticket type
  #
  # @param ticket_type_id [Integer]
  # @return [ActiveRelation]
  def ticket_type_tickets ticket_type_id
    if self.ticket_types.where(id: ticket_type_id).size.zero?
      raise_error("Given ticket type not found on transaction")
    end

    self.tickets.where(ticket_type_id: ticket_type_id)
  end

  # Creates Ticket objects based on bought_quantity attr passed on ticket_types param.
  # The ticket_types's structure is:
  #  [#<TicketType ...bought_quantity: 3>, #<TicketType ...bought_quantity: 2>]
  #
  # @param ticket_types [Array]
  def load_tickets transaction_event, ticket_types
    ticket_types.each do |ticket_type|
      available_tickets = true

      0..ticket_type.bought_quantity.times do
        ticket = Ticket.new(ticket_type_id: ticket_type.id, transaction_id: self.id)
        available_tickets = ticket.save
      end

      unless available_tickets
        errors.add(:base, I18n.t("activerecord.errors.models.transaction.not_available_tickets",
          ticket_type_name: ticket_type.name))
      end
    end

    sell_limit = transaction_event.sell_limit || GlobalConfiguration.sell_limit
    if self.tickets.count > sell_limit
      raise_error("Sell limit has been exceeded")
    end
  end

  def self.validate_user_existance user_id
    user = User.find_by_id user_id
    raise_error("Invalid user given") if user.nil?
  end

  # Validates that each ticket type has defined bought quantity.
  #
  # @param ticket_types [Array]
  def self.validate_ticket_types ticket_types
    if ticket_types.nil? or !ticket_types.kind_of? Array
      raise_error("Invalid ticket types array")
    end

    ticket_types.each do |ticket_type|
      unless ticket_type.kind_of? TicketType
        raise_error("This is not a ticket type object")
      end

      type = TicketType.find_by_id ticket_type[:id]

      unless type
        raise_error("Inexistent ticket type")
      end

      unless ticket_type.bought_quantity
        raise_error("bought quantity not defined for ticket type")
      end
    end

    unless TicketType.ticket_types_for_same_event?(ticket_types)
      raise_error("Ticket types form multiple events found")
    end
  end

  def self.log_error error_msg
    Rails.logger.error(error_msg.red)
  end

  def self.raise_error message
    raise PTE::Exceptions::TransactionError.new(message)
  end
end
