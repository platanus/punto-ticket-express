module PTE
  module Promotion
    class Xls
      def self.load_codes_into_promotion promotion, xls
        PTE::Xls.save xls, "xls_codes", "codes.xls"
        return {result: :success}
      end
    end
  end
end
