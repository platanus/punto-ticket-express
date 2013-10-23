class Transaction < ActiveRecord::Base
  attr_accessible :amount, :details, :payment_status, :token, :transaction_time, :user_id, :nested_resource_attributes, :error
  attr_accessor :payment_method

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
  # @param ticket_types [Array] each row is a hash with qty key
  #  that represents the quantity to sell from a given ticket type
  #  and id key corresponding with the ticket type to sell.
  #  The param has the following structure:
  #   [{id: 1, qty: 3},{id: 2, qty: 4}]
  # @return [Transaction] with PTE::PaymentStatus.processing as payment_status
  def self.begin user_id, ticket_types, nested_resource_data
    begin
      transaction = Transaction.new

      ActiveRecord::Base.transaction do
        validate_user_existance(user_id)
        load_ticket_types!(ticket_types)
        transaction.load_nested_resource(nested_resource_data)
        transaction.save_beginning_status(user_id)
        transaction.load_tickets(ticket_types)
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
  # If this method is executed with errors, the transaction will be
  # returned with error field setted, .valid? method false and, if token
  # exists, payment_status with value PTE::PaymentStatus.inactive
  #
  # @param headers [Hash]
  # @param params [Hash]
  # @return [Transaction]
  def self.finish token
    begin
      validate_token(token)
      transaction = validate_transaction_for_completion(token)
      transaction.save_finished_status
      transaction

    rescue Exception => e
      get_transaction_with_error(e.message)
    end
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

  def self.validate_token token
    raise_error("Invalid token given") if(!token or token.to_s.empty?)
  end

  def with_errors?
    !self.error.nil?
  end

  # Loads NestedResource instance into transaction
  # @param [Hash] The structure of nested_resource_data param must be:
  #  {attrs: {attr1: 'value1', attr2: 'value1', attr3: 'value3'}, required_attributes: [:attr1, :attr2]}
  def load_nested_resource nested_resource_data
    return unless nested_resource_data

    begin
      nr = NestedResource.new(nested_resource_data[:attrs])
      nr.required_attributes = nested_resource_data[:required_attributes]
      self.nested_resource = nr
    rescue
      Transaction.raise_error("Invalid nested_resource_data structure given")
    end
  end

  # Calculates the total amount of the transaction based on ticket prices
  #
  # @return [Fixnum]
  def total_amount
    tickets_data_by_type.inject(0) do |amount, type_data|
      amount += type_data[:total]
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

  # Checks if transaction (for a given token) exist on db
  # Checks if transaction was procesed already.
  #
  # @param token [String]
  # @return [Transaction]
  def self.validate_transaction_for_completion token
    transaction = Transaction.find_by_token token
    raise_error("Transaction not found for given token") unless transaction
    raise_error("Transaction with given token was processed already") unless transaction.can_finish?
    transaction
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

  def save_finished_status
    self.update_attribute(:payment_status, PTE::PaymentStatus.completed)
  end

  # Returns transaction's data grouped by ticket type.
  # By type it returns tickets count, type price and count x price.
  # Response example:
  #  [{count: 3, price: 200, total: 600}, {count: 2, price: 100, total: 200}]
  #
  # @return [Array]
  def tickets_data_by_type
    self.ticket_types.inject([]) do |result, ticket_type|
      query = self.tickets.where(["tickets.ticket_type_id = ?", ticket_type.id])
      result << {
        tickets: nil,
        type_name: ticket_type.name,
        count: query.count,
        price: ticket_type.price,
        total: (query.count * ticket_type.price)
      }
    end
  end

  # Creates Ticket objects based on id and qty keys passed on ticket_types param.
  # The ticket_types's structure is:
  #  [{id: 1, qty: 3, object: TicketType},{id: 2, qty: 4, object: TicketType}]
  #
  # @param ticket_types [Array]
  def load_tickets ticket_types
    ticket_types.each do |ticket_type|
      available_tickets = true

      0..ticket_type[:qty].to_i.times do
        ticket = Ticket.new(ticket_type_id: ticket_type[:id], transaction_id: self.id)
        available_tickets = false unless ticket.save
      end

      unless available_tickets
        errors.add(:base, I18n.t("activerecord.errors.models.transaction.not_available_tickets",
          ticket_type_name: ticket_type[:object].name))
      end
    end
  end

  def self.validate_user_existance user_id
    user = User.find_by_id user_id
    raise_error("Invalid user given") if user.nil?
  end

  # Loads a TicketType object for each row on ticket_types attribute.
  # The initial structure of ticket_types will be:
  #  [{id: 1, qty: 3},{id: 2, qty: 4}]
  # The structure of ticket_types will be as the following after execute this method successfully.
  #  [{id: 1, qty: 3, object: TicketType},{id: 2, qty: 4, object: TicketType}]
  #
  # @param ticket_types [Array] with the structure:
  def self.load_ticket_types! ticket_types
    if ticket_types.nil? or !ticket_types.kind_of? Array
      raise_error("Invalid ticket types array")
    end

    ticket_types.each do |ticket_type|
      unless ticket_type.kind_of? Hash and
        ticket_type.has_key? :id and ticket_type.has_key? :qty
        raise_error("Invalid ticket type format")
      end

      type = TicketType.find_by_id ticket_type[:id]

      if type
        ticket_type[:object] = type
      else
        raise_error("Inexistent ticket type")
      end
    end

    unless TicketType.ticket_types_for_same_event?(ticket_types.map{ |tt| tt[:object] })
      raise_error("Ticket types form multiple events found")
    end
  end

  def self.log_error error_msg
    Rails.logger.error(error_msg)
  end

  def self.raise_error message
    raise PTE::Exceptions::TransactionError.new(message)
  end
end
