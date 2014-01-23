module PTE
  module Promotion
    class Xls
      def self.load_codes_into_promotion promotion, xls
        tmp_directory = PTE::Xls.save xls, "xls_promo_codes", "codes.xls"
        PTE::Xls.read(tmp_directory + "/codes.xls") do |sheet, row|
          code = row.first.to_s
          break if code.empty?
          puts code
        end
        return {result: :success}
      end
    end
  end
end
