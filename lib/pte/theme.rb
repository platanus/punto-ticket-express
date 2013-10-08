module PTE
  class Theme
    TYPES = [:default, :dark, :burnout, :azul, :nature, :jelly]

    TYPES.each do |type_name|
      self.class.class_eval do
        define_method(type_name) do
          type_name.to_s
        end
      end
    end

    def self.human_name theme
      I18n.t("pte.theme.types.#{theme.to_s}")
    end

    def self.is_valid? type_name
      return false if type_name.nil? or type_name.empty?
      TYPES.include? type_name.to_sym
    end

    def self.types_to_a
      # assets url
      themes_path = ActionController::Base.helpers.asset_path 'themes/'
      # returns a hash with an url and name for each theme
      TYPES.map {|theme| {name: theme, url: "#{themes_path}#{theme}.css"}}
    end
  end
end
