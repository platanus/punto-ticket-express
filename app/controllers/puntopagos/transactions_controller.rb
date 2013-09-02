class Puntopagos::TransactionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:notification, :error, :success]

  def notification
    result = Transaction.finish(request.headers, params)
    render json: result
  end

  def new
    authorize! :create, Transaction
    @transaction = Transaction.new
    @ticket_types = params[:ticket_types].values
  end

  def create
    @transaction = Transaction.begin current_user.id, params[:ticket_types]
    authorize! :create, @transaction

    if @transaction.errors.any?
      @ticket_types = params[:ticket_types]
      render action: "new"

    else
      puntopagos_response = @transaction.create_puntopagos_transaction

      if puntopagos_response.success?
        redirect_to puntopagos_response.payment_process_url

      else
        @ticket_types = params[:ticket_types]
        render action: "new"
      end
    end
  end

  def show
    authorize! :read, @transaction
  end
end
