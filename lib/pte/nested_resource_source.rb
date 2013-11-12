module PTE
  class NestedResourceSource
    TYPES = [:all, :transaction, :tickets]

    PTE::NestedResourceSource::TYPES.each do |type_name|
      self.class.class_eval do
        define_method(type_name) do
          type_name.to_s
        end
      end
    end

    def self.human_name status_name
      I18n.t("pte.nested_resource_source.#{status_name}", default: "Undefined source" )
    end

    def self.types_to_a exclude = []
      types = []
      TYPES.each do |type|
       types << [human_name(type.to_s), type] unless exclude.include? type
      end
      types
    end
  end
end
