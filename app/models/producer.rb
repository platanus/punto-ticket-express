class Producer < ActiveRecord::Base
  attr_accessible :address, :contact_email, :contact_name, :description, :name, :phone, :rut, :website, :confirmed

  has_and_belongs_to_many :users
  has_many :events, dependent: :destroy
  has_many :ticket_types, through: :events
  has_many :tickets, through: :ticket_types

  validates :name, presence: true
  validates :website,
    format: {with: %r{\Ahttps?:\/\/([^\s:@]+:[^\s:@]*@)?[A-Za-z\d\-]+(\.[A-Za-z\d\-]+)+\.?(:\d{1,5})?([\/?]\S*)?\z}i,
    message: I18n.t("activerecord.errors.messages.invalid_url")},
    allow_nil: true, allow_blank: true
  validates :contact_email,
    email_format: {message: I18n.t("activerecord.errors.messages.invalid_email"),
    allow_nil: true, allow_blank: true}

  before_destroy :can_destroy?
  after_create :validate_one_owner_at_least
  after_save :validate_one_owner_at_least

  private

    def validate_one_owner_at_least
      if users.count.zero?
        errors.add(:base, :one_owner_at_least)
        return false
      end
    end

    def can_destroy?
      unless self.tickets.count.zero?
        errors.add(:base, :has_related_tickets)
        return false
      end
    end

end
