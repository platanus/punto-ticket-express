module PTE
  module Exceptions
    class TransactionError < Exception; end
    class PromotionError < Exception; end
    class GlobalConfigurationError < Exception; end
    class RowStatusError < Exception; end
    class XlsNoFileError < Exception; end
    class InvalidXlsFileError < Exception; end
    class PromotionXlsError < Exception; end
  end
end
