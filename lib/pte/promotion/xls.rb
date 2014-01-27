module PTE
  module Promotion
    module Xls
      def save_temp_xls_codes_file xls
        PTE::Xls.save xls, "xls_promo_codes", "codes.xls"
      end

      def load_codes_into_promotion promotion_id, xls_directory
        errors = []
        begin
          promotion = self.find(promotion_id)
          ActiveRecord::Base.transaction do
            PTE::Xls.read(xls_directory + "/codes.xls") do |sheet, row|
              code = row.first.to_s
              break if code.empty?
              row_idx = row.idx + 1
              promo_code = PromotionCode.new(code: code)
              promo_code.promotion = promotion
              errors << {row: row_idx, errors: promo_code.errors.messages} unless promo_code.save
            end

            raise PTE::Exceptions::PromotionXlsError.new unless errors.size.zero?
          end

          PromotionMailer.sucessfully_codes_load(promotion).deliver

        rescue PTE::Exceptions::PromotionXlsError => e
          puts e.message
          puts errors.inspect
          PromotionMailer.failed_codes_load(promotion, errors).deliver
        end
      end
    end
  end
end
