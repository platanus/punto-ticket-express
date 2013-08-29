module PTE
  module Transaction
    module CalculatedAttributes

      def event
        events.first
      end

      def event_name
        event.try(:name)
      end

      def event_start_time
        event.try(:start_time)
      end

      def event_end_time
        event.try(:end_time)
      end

      def total_amount
        tickets_data_by_type.inject(0.0) do |amount, type_data|
          amount += type_data[:total]
        end
      end

      def RFC1123_date
        return nil unless self.transaction_time
        transaction_time.httpdate
      end

      def tickets_quantity
        tickets.count
      end

      def total_amount_to_s
        "%0.2f" % total_amount
      end

      def auth action_path
        message = "#{action_path}\n" +
        "#{self.id}\n" +
        "#{self.total_amount_to_s}\n" +
        "#{self.RFC1123_date}"
        signed_message = Digest::HMAC.hexdigest(message, ::Transaction.key_secret, Digest::SHA1)
        "PP#{::Transaction.key_id}:#{signed_message}"
      end

    end
  end
end