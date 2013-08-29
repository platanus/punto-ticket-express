class Transaction < ActiveRecord::Base
  extend PTE::Transaction::Config
  include PTE::Transaction::CalculatedAttributes

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
        transaction.load_beginning_status(user_id)
        transaction.load_tickets(ticket_types)
        if transaction.errors.any?
          @@log.fatal transaction.errors.messages.to_s.red
          raise ActiveRecord::Rollback
        end
        transaction.create_puntopagos_transaction
      end

    rescue Exception => e
      log_error(e)
      transaction.errors.add(:base, :unknown_error)
    end

    transaction
  end

  def self.finish puntopagos_token, authorization_hash, values
    begin
      validate_mandatory_values(values)
      transaction = transaction_by_token(puntopagos_token)

      unless transaction.can_finish?
        raise_error("The transaction with token #{puntopagos_token} was processed already")
      end

      unless transaction.auth_match?(authorization_hash)
        raise_error("Internal authorization_hash does not match with puntopagos authorization_hash")
      end

      transaction.payment_status = PTE::PaymentStatus.completed
      #transaction.payment_method = values[:payment_method] TODO
      #transaction.approbation_date = values[:approbation_date]
      transaction.save

      return {
        respuesta: SUCCESS_CODE,
        token: puntopagos_token}

    rescue Exception => e
      log_error(e)

      if transaction
        transaction.payment_status = PTE::PaymentStatus.inactive
        #transaction.error = e.message TODO
        transaction.save
      end

      return {
        respuesta: ERROR_CODE,
        error: e.message,
        token: puntopagos_token}
    end
  end

  def auth_header action_path
    {"Fecha" => self.RFC1123_date,
      "Autorizacion" => auth(action_path)}
  end

  def body_on_create
    {"trx_id" => self.id,
     "medio_pago" => "999", #TODO: de donde saco esto?
     "monto" => self.total_amount_to_s}
  end

  def create_puntopagos_transaction
    options = {}
    options[:body] = body_on_create
    options[:headers] = auth_header(Transaction.create_path)
    response = HTTParty.post(Transaction.create_url, options)

    if response.code != 201 and response.code != 200
      Transaction.raise_error("Puntopagos response - status: #{response.code} and message: #{response.message}")
    end

    body = response.parsed_response

    if body["respuesta"] == Transaction::ERROR_CODE
      Transaction.raise_error("Puntopagos response - respuesta: #{response.code} and error: #{body["error"]}")
    end

    if body["trx_id"].to_i != self.id
      Transaction.raise_error("Puntopagos response - trx_id does not match with transcation.id")
    end

    self.token = body["token"]
    self.amount = body["monto"]
    self.save
  end

  def load_beginning_status user_id
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

      0..ticket_type[:quantity].to_i.times do
        ticket = Ticket.new(ticket_type_id: ticket_type[:id], transaction_id: self.id)
        available_tickets = false unless ticket.save
      end

      unless available_tickets
        errors.add(:base, I18n.t("activerecord.errors.models.transaction.not_available_tickets",
          ticket_type_name: ticket_type[:object].name))
      end
    end
  end

  def auth_match? authorization_hash
    return false unless authorization_hash
    transaction_auth = self.auth(Transaction.notification_path)
    transaction_auth == authorization_hash
  end

  def can_finish?
    self.payment_status == PTE::PaymentStatus.processing
  end

  def self.transaction_by_token token
    transaction = Transaction.find_by_token token
    return transaction if transaction
    raise_error("Does not exist transaction with puntopagos_token = #{token}")
  end

  def self.validate_mandatory_values values
    if values.nil? or values.empty?
      raise_error("Undefined values hash")
    end

    unless values.has_key? :id
      raise_error("Undefined id key into values hash")
    end

    unless values.has_key? :amount
      raise_error("Undefined amount key into values hash")
    end

    unless values.has_key? :payment_method
      raise_error("Undefined payment_method key into values hash")
    end

    unless values.has_key? :approbation_date
      raise_error("Undefined approbation_date key into values hash")
    end
  end

  def self.validate_user_existance user_id
    user = User.find_by_id user_id
    if user.nil?
      raise_error("Invalid user given")
    end
  end

  def self.load_ticket_types! ticket_types
    if ticket_types.nil? or !ticket_types.kind_of? Array
      raise_error("Invalid ticket types array")
    end

    ticket_types.each do |ticket_type|
      unless ticket_type.kind_of? Hash and
        ticket_type.has_key? :id and ticket_type.has_key? :quantity
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
end