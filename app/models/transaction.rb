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

  def self.configure puntopagos_url, key_id, key_secret
    @@puntopagos_url = get_valid_url(puntopagos_url)
    @@key_id = key_id
    @@key_secret = key_secret
    @@log = Logger.new(STDOUT)
  end

  def self.get_valid_url url
    parts = url.split("//")

    if parts.size == 1
      url = parts.first.split("/").first
      url = "http://#{url}"

    else
      protocol = parts.first
      url = parts.second.split("/").first
      url = "#{protocol}//#{url}"
    end

    return url if validate_url(url)
  end

  def self.validate_url url
    if url =~ /^#{URI::regexp}$/
      return true
    end

    raise PTE::Exceptions::TransactionError.new(
      "Invalid url given")
  end

  def self.safe_puntopagos_action action_path
    url = [@@puntopagos_url,
      action_path.split("/").reject do |v|
        v.empty?
      end.join("/")
    ].join("/")

    return url if validate_url(url)
  end

  def puntopagos_url
    unless defined? @@puntopagos_url
      raise PTE::Exceptions::TransactionError.new(
        "puntopagos_url class variable not initialized")
    end

    @@puntopagos_url
  end

  def key_id
    unless defined? @@key_id
      raise PTE::Exceptions::TransactionError.new(
        "key_id class variable not initialized")
    end

    @@key_id
  end

  def key_secret
    unless defined? @@key_secret
      raise PTE::Exceptions::TransactionError.new(
        "key_secret class variable not initialized")
    end

    @@key_secret
  end

  def get_auth_header url
    message = "#{url}\n" +
    "#{self.id}\n" +
    "#{self.total_amount_to_s}\n" +
    "#{self.RFC1123_date}"

    signed_message = Digest::HMAC.hexdigest(message, key_secret, Digest::SHA1)
    auth = "PP#{key_id}:#{signed_message}"

    {"Fecha" => self.RFC1123_date,
      "Autorizacion" => auth}
  end

  def event
    self.events.first
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

  def tickets_quantity
    self.tickets.count
  end

  def total_amount
    self.tickets_data_by_type.inject(0.0) do |amount, type_data|
      amount += type_data[:total]
    end
  end

  def RFC1123_date
    return nil unless self.transaction_time
    self.transaction_time.httpdate
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

  def self.begin user_id, ticket_types
    transaction = Transaction.new

    begin
      ActiveRecord::Base.transaction do
        validate_user_existance(user_id)
        load_ticket_types!(ticket_types)
        transaction.load_beginning_status(user_id)
        transaction.load_tickets(ticket_types)
        raise ActiveRecord::Rollback if transaction.errors.any?
        transaction.create_puntopagos_transaction
      end

    rescue Exception => e
      @@log.fatal e.message
      transaction.errors.add(:base, :unknown_error)
    end

    transaction
  end

  def body_on_create
    {"trx_id" => self.id,
     "medio_pago" => "999", #TODO: de donde saco esto?
     "monto" => self.total_amount_to_s}
  end

  def total_amount_to_s
    "%0.2f" % self.total_amount
  end

  def process_url
    Transaction.safe_puntopagos_action("/puntopagos/transactions/procesar/#{self.token}")
  end

  def create_url
    Transaction.safe_puntopagos_action('/puntopagos/transactions/crear')
  end

  def create_puntopagos_transaction
    options = {}
    url = create_url
    options[:body] = body_on_create
    options[:headers] = get_auth_header(url)
    response = HTTParty.post(url, options)

    puts "#### HEADERS ####"
    puts options[:headers]
    puts response.headers.inspect

    if response.code != 201 and response.code != 200
      raise PTE::Exceptions::TransactionError.new(
        "Puntopagos response - status: #{response.code} and message: #{response.message}")
    end

    body = response.parsed_response

    if body["respuesta"] == Transaction::ERROR_CODE
      raise PTE::Exceptions::TransactionError.new(
        "Puntopagos response - respuesta: #{response.code} and error: #{body["error"]}")
    end

    if body["trx_id"].to_i != self.id
      raise PTE::Exceptions::TransactionError.new(
        "Puntopagos response - trx_id does not match with transcation.id")
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

  def self.validate_user_existance user_id
    user = User.find_by_id user_id
    if user.nil?
      raise PTE::Exceptions::TransactionError.new("Invalid user given")
    end
  end

  def self.load_ticket_types! ticket_types
    if ticket_types.nil? or !ticket_types.kind_of? Array
      raise PTE::Exceptions::TransactionError.new("Invalid ticket types array")
    end

    ticket_types.each do |ticket_type|
      unless ticket_type.kind_of? Hash and
        ticket_type.has_key? :id and ticket_type.has_key? :quantity
        raise PTE::Exceptions::TransactionError.new("Invalid ticket type format")
      end

      type = TicketType.find_by_id ticket_type[:id]

      if type
        ticket_type[:object] = type
      else
        raise PTE::Exceptions::TransactionError.new("Inexistent ticket type")
      end
    end

    unless TicketType.ticket_types_for_same_event?(ticket_types.map{ |tt| tt[:object] })
      raise PTE::Exceptions::TransactionError.new("Ticket types form multiple events found")
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
end