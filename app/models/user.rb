class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role
  # attr_accessible :title, :body

  has_many :events
  has_many :transactions
  has_many :tickets, through: :transactions
  has_many :ticket_types, through: :events
  has_and_belongs_to_many :producers

  PTE::Role::TYPES.each do |type_name|
    define_method("#{type_name}?") do
      PTE::Role.same? self.role, type_name
    end
  end

  def human_role
    PTE::Role.human_name self.role
  end
end
