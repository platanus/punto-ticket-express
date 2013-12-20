module PTE
  module Exceptions
    class TransactionError < Exception; end
    class PromotionError < Exception; end
    class GlobalConfigurationError < Exception; end
    class RowStatusError < Exception; end
  end
end
