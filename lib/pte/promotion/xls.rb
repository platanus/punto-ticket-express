module PTE
  module Promotion
    class Xls
      def self.load_codes_into_promotion promotion, xls
        errors = []
        begin
          ActiveRecord::Base.transaction do
            tmp_directory = PTE::Xls.save xls, "xls_promo_codes", "codes.xls"
            PTE::Xls.read(tmp_directory + "/codes.xls") do |sheet, row|
              code = row.first.to_s
              break if code.empty?
              row_idx = row.idx + 1
              promo_code = PromotionCode.new(code: code)
              promo_code.promotion = promotion
              errors << {row: row_idx, errors: promo_code.errors.messages} unless promo_code.save
            end

            raise PTE::Exceptions::PromotionXlsError.new unless errors.size.zero?
          end

          # TODO: send email to notificate user that codes are created sucessfully
        rescue PTE::Exceptions::PromotionXlsError => e
          puts e.message
          puts errors.inspect
          # TODO: send email to notificate user xls has errors
        end
      end
    end
  end
end
