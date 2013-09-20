class ActiveRecord::Base
	def self.required? attr
		validators_on(attr).map(&:class).include?(
			ActiveModel::Validations::PresenceValidator)
	end
end