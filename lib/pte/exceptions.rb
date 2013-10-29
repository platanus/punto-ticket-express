module PTE
  module Exceptions
    class TransactionError < Exception; end
    class PromotionError < Exception; end
    class GlobalConfigurationError < Exception; end
  end
end
