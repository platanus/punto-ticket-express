module PTE
  module Transaction
    module Config

      def configure values
        unless(values.has_key? :puntopagos_url and
          values.has_key? :key_id and
          values.has_key? :key_secret and
          values.has_key? :create_path and
          values.has_key? :process_path and
          values.has_key? :notification_path)
           raise PTE::Exceptions::TransactionError.new(
             "Missing configuration values")
        end

        values.each do |attr, value|
          eval("@@#{attr} = '#{value}'")

          self.class.class_eval do
            define_method(attr) do
              eval("@@#{attr}")
            end
          end
        end
      end

      def log_error exception
        puts exception.message.red
        puts exception.backtrace.first.red
      end

      def raise_error message

      end

      def get_valid_url url
        parts = url.split("//")

        if parts.size == 1
          url = parts.first.split("/").first
          url = "http://#{url}"

        else
          protocol = parts.first
          url = parts.second.split("/").first
          url = "#{protocol}//#{url}"
        end

        return url if validate_url(url)
      end

      def validate_url url
        if url =~ /^#{URI::regexp}$/
          return true
        end

        raise PTE::Exceptions::TransactionError.new(
          "Invalid url given")
      end

      def safe_puntopagos_action action_path
        url = [@@puntopagos_url,
          action_path.split("/").reject do |v|
            v.empty?
          end.join("/")
        ].join("/")

        return url if validate_url(url)
      end

      def process_url token
        safe_puntopagos_action("#{process_path}/#{token}")
      end

      def create_url
        safe_puntopagos_action(create_path)
      end
    end

  end
end
