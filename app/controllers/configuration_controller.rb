class ConfigurationController < ApplicationController
  def account
    authorize! :config, :account
    @user = current_user
  end

  def producers
    authorize! :config, :producers
    @producers = current_user.producers
  end

  def transactions
    authorize! :config, :transactions
    @transactions = current_user.transactions
  end
end
