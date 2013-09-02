class Transaction < ActiveRecord::Base
 # attrs
  attr_accessible :amount, :details, :payment_status, :token, :transaction_time, :user_id

  # relationship
  belongs_to :user
  has_many :tickets
  has_many :ticket_types, through: :tickets, uniq: true
  has_many :events, through: :ticket_types, uniq: true

  #delegates
  delegate :email, to: :user, prefix: true, allow_nil: true

  SUCCESS_CODE = "00"
  ERROR_CODE = "99"

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

  def create_puntopagos_transaction
    request = PuntoPagos::Request.new
    response = request.create(self.id.to_s, self.total_amount.to_s)

    if response.success?
      update_attribute(:token, response.get_token)
    else
      self.errors.add(:base, response.get_error)
    end

    response
  end

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

  def total_amount
    tickets_data_by_type.inject(0) do |amount, type_data|
      amount += type_data[:total]
    end
  end

  def tickets_quantity
    tickets.count
  end

  def can_finish?
    self.payment_status == PTE::PaymentStatus.processing
  end

  def self.transaction_by_token token
    transaction = Transaction.find_by_token token
    return transaction if transaction
    raise_error("Does not exist transaction with puntopagos_token = #{token}")
  end

  def save_beginning_status user_id
    self.payment_status = PTE::PaymentStatus.processing
    self.user_id = user_id
    self.transaction_time = Time.now
    self.save
  end

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