module PTE
  class Role
    TYPES = [:user, :admin]

    TYPES.each do |type_name|
      self.class.class_eval do
        define_method(type_name) do
          type_name.to_s
        end
      end
    end

    def self.same? role_one, role_two
      return false unless is_valid?(role_one) and is_valid?(role_two)
      role_one.to_sym == role_two.to_sym
    end

    def self.human_name role
      I18n.t("pte.role.types.#{role}", default: "Undefined role name" )
    end

    def self.is_valid? type_name
      return false if type_name.nil? or type_name.empty?
      TYPES.include? type_name.to_sym
    end

    def self.types_to_a
      TYPES.map {|role| [human_name(role), role]}
    end
  end
end
