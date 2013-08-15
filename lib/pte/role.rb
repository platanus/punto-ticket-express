module PTE
  class Role
    TYPES = [:participant, :organizer, :admin]

    PTE::Role::TYPES.each do |type_name|
      self.class.class_eval do
        define_method(type_name) do 
          type_name.to_s
        end
      end
    end

    def self.same? role_one, role_two
      return false if !PTE::Role.is_valid?(role_one) or !PTE::Role.is_valid?(role_two)
      role_one.to_sym == role_two.to_sym
    end

    def self.human_name role
      I18n.t("pte.role.types.#{role}", default: "Undefined role name" )
    end

    def self.is_valid? type_name
      return false if type_name.nil? or type_name.empty?
      PTE::Role::TYPES.include? type_name.to_sym
    end
  end
end
