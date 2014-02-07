module PTE
  module Promotion
    module Xls
      def self.included(base)
        base.send :include, InstanceMethods
        base.send :extend, ClassMethods
      end

      module ClassMethods
      end

      module InstanceMethods
        def create_with_codes
          begin
            ActiveRecord::Base.transaction do
              self.save!
              if codes_file
                xls_directory = self.save_temp_xls_codes_file
                self.load_codes_into_promotion xls_directory
              end

              return true
            end

          rescue ActiveRecord::RecordInvalid => e
            return false

          rescue Ole::Storage::FormatError
            self.errors.add(:codes_file, :must_be_xls)
            return false

          rescue PTE::Exceptions::XlsNoFileError
            self.errors.add(:codes_file, :no_file_given)
            return false

          rescue PTE::Exceptions::PromotionXlsError => e
            msg = I18n.t(
              'activerecord.errors.models.promotion.attributes.codes_file.row_error',
              row_number: e.row_number)

            self.errors.add(:codes_file, msg)
            return false
          end
        end

        def save_temp_xls_codes_file
          PTE::Xls.save self.codes_file, "xls_promo_codes", "codes.xls"
        end

        def load_codes_into_promotion xls_directory
          ActiveRecord::Base.transaction do
            PTE::Xls.read(xls_directory + "/codes.xls") do |sheet, row|
              code = row.first.to_s
              return true if code.empty?
              row_idx = row.idx + 1
              promo_code = PromotionCode.new(code: code)
              promo_code.promotion = self
              if !promo_code.save
                exception = PTE::Exceptions::PromotionXlsError.new
                exception.row_number = row_idx
                exception.message = promo_code.errors.messages
                raise exception
              end
            end

            return true
          end
        end

      end
    end
  end
end
