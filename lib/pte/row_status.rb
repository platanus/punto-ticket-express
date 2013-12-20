module PTE
  module RowStatus
    ROW_ACTIVE = 1
    ROW_DELETED = 0

    def self.included(base)
      base.send :include, InstanceMethods
      base.send :extend, ClassMethods
      base.before_save :check_status_validity
      base.before_create :check_status_validity
    end

    module ClassMethods
      def row_statuses
        [ROW_ACTIVE, ROW_DELETED]
      end
    end

    module InstanceMethods
      def check_status_validity
        if !self.is_row_status_valid?
          raise PTE::Exceptions::RowStatusError.new(
            "Status must be one of these: #{self.class.row_statuses.join(', ')}")
        end
      end

      def is_row_status_valid?
        self.class.row_statuses.include? self.status
      end
    end
  end
end
