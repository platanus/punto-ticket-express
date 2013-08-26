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
        if transaction.errors.any?
          raise ActiveRecord::Rollback
        end
      end

    rescue Exception => e
      puts e.message
      transaction.errors.add(:base, :unknown_error)
    end

    puts transaction.errors.messages.inspect
    transaction
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