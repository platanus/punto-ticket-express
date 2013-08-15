class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  # attr_accessible :title, :body

  has_many :events
  has_many :tickets
  has_many :ticket_types, through: :events

  def is? role
    PTE::Role.same? self.role, role
  end

  def human_role
    PTE::Role.human_name self.role
  end
end
