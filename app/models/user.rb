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
  has_many :tickets
  has_many :ticket_types, through: :events

  PTE::Role::TYPES.each do |type_name|
    define_method("#{type_name}?") do 
      PTE::Role.same? self.role, type_name
    end
  end

  def human_role
    PTE::Role.human_name self.role
  end
end
