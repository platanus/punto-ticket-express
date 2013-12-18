class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me, :role, :name

  before_destroy :can_destroy?

  validates :name, presence: true
  validates :role, presence: true

  has_many :events, dependent: :destroy
  has_many :transactions
  has_many :tickets, through: :transactions
  has_many :ticket_types, through: :events
  has_many :events_tickets, through: :ticket_types, source: :tickets
  has_and_belongs_to_many :producers

  scope :admins, where(role: PTE::Role.admin)

  PTE::Role::TYPES.each do |type_name|
    define_method("#{type_name}?") do
      PTE::Role.same? self.role, type_name
    end
  end

  def identifier
    return self.name if self.name
    self.email
  end

  def unconfirmed_producers
    self.producers.where(confirmed: false)
  end

  def human_role
    PTE::Role.human_name self.role
  end

  def completed_transactions
    self.transactions.where(payment_status: PTE::PaymentStatus.completed)
  end

  private

    def can_destroy?
      unless self.tickets.count.zero?
        errors.add(:base, :has_related_tickets)
        return false
      end

      unless self.events_tickets.count.zero?
        errors.add(:base, :has_related_event_tickets)
        return false
      end
    end
end
