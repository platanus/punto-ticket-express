class ConfigurationController < ApplicationController
  def account
    authorize! :config, :account
    @user = current_user
  end

  def update_account
    authorize! :config, :account
    @user = current_user

    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to configuration_account_path, notice: t("configuration.account.successfully_updated_message") }
        format.json { head :no_content }
      else
        format.html { render action: "account" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def producers
    authorize! :config, :producers
    @producers = current_user.producers
  end

  def transactions
    authorize! :config, :transactions
    @transactions = current_user.transactions.order("transaction_time desc")
  end
end
