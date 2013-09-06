class ConfigurationController < ApplicationController
  def account
    authorize! :config, :account
  end

  def producers
    authorize! :config, :producers
  end

  def transactions
    authorize! :config, :transaction
  end
end
