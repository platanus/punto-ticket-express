class Transaction < ActiveRecord::Base
 # attrs
  attr_accessible :amount, :details, :payment_status, :token, :transaction_time, :user_id

  # relationship
  belongs_to :user
  has_many :tickets
  has_many :ticket_types, through: :tickets, uniq: true
  has_many :events, through: :ticket_types, uniq: true
  has_one :nested_resource, as: :nestable

  #delegates
  delegate :email, to: :user, prefix: true, allow_nil: true

  SUCCESS_CODE = "00"
  ERROR_CODE = "99"

  def event
    events.first
  end

  def event_name
    event.try(:name)
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
  def self.begin user_id, ticket_types
    transaction = Transaction.new

    begin
      ActiveRecord::Base.transaction do
        validate_user_existance(user_id)
        load_ticket_types!(ticket_types)
        transaction.save_beginning_status(user_id)
        transaction.load_tickets(ticket_types)
        if transaction.errors.any?
          @@log.fatal transaction.errors.messages.to_s.red
          raise ActiveRecord::Rollback
        end
      end

    rescue Exception => e
      log_error(e)
      transaction.errors.add(:base, :unknown_error)
    end

    transaction
  end

  # Ends a transaction.
  # Checks if header data sent by puntopagos and token are correct.
  # If this method is executed sucessfully, the transaction will have payment_status
  # with value PTE::PaymentStatus.completed and return value will be:
  #  {respuesta: "00", token: "xxxxxxxxx"}
  # If this method is executed with errors, the transaction will have payment_status
  # PTE::PaymentStatus.inactive and return value will be:
  #  {respuesta: "99", token: "xxxxxxxxx", error: "Error message"}
  #
  # @param headers [Hash]
  # @param Params [Hash]
  # @return [Hash]
  def self.finish headers, params
    puntopagos_token = params[:token]

    begin
      notification = PuntoPagos::Notification.new

      if !notification.valid? headers, params
        raise_error("Transaction's notification invalid")
      end

      transaction = transaction_by_token(puntopagos_token)

      unless transaction.can_finish?
        raise_error("The transaction with token #{puntopagos_token} was processed already")
      end

      transaction.update_attribute(:payment_status, PTE::PaymentStatus.completed)

      return {
        respuesta: SUCCESS_CODE,
        token: puntopagos_token}

    rescue Exception => e
      log_error(e)

      if transaction
        transaction.payment_status = PTE::PaymentStatus.inactive
        transaction.error = e.message
        transaction.save
      end

      return {
        respuesta: ERROR_CODE,
        error: e.message,
        token: puntopagos_token}
    end
  end

  # Sends a request to create a transaction with puntopagos.
  # Updates the token attribute if response is satisfactory.
  #
  # @return [PuntoPagos::Response]
  def create_puntopagos_transaction
    request = PuntoPagos::Request.new
    response = request.create(self.id.to_s, self.total_amount_to_s)

    if response.success?
      update_attribute(:token, response.get_token)
    else
      self.errors.add(:base, response.get_error)
    end

    response
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

  def self.transaction_by_token token
    transaction = Transaction.find_by_token token
    return transaction if transaction
    raise_error("Does not exist transaction with puntopagos_token = #{token}")
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
        count: query.count,
        price: ticket_type.price,
        total: (query.count * ticket_type.price)
      }
    end
  end

  # Creates Ticket objects based on id and qty keys passed on ticket_types param.
  # The structure of tycket_types is:
  #  [{id: 1, qty: 3, object: TicketType},{id: 2, qty: 4, object: TicketType}]
  #
  # @param ticket_types [Array] with the structure
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

  def self.log_error exception
    puts exception.message.red
    puts exception.backtrace.first.red
  end

  def self.raise_error message
    raise PTE::Exceptions::TransactionError.new(message)
  end
end
