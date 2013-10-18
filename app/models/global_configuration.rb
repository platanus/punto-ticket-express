class GlobalConfiguration < ActiveRecord::Base
  attr_accessible :fixed_fee, :percent_fee

  validates :percent_fee, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :fixed_fee, numericality: { greater_than_or_equal_to: 0 }

  before_destroy :cancel_destroy

  def self.config
    GlobalConfiguration.first
  end

  def self.fixed_fee
    self.config.fixed_fee
  end

  def self.percent_fee
    self.config.percent_fee
  end

  private

  def cancel_destroy
    raise PTE::Exceptions::GlobalConfigurationError.new(
      "Global Configuration instance can't be destroyed")
  end
end
