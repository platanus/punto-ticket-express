class Puntopagos::TransactionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:notification, :error, :success]
  before_filter :load_ticket_types, :only => [:new, :create]
  before_filter :load_nested_attributes, :only => [:new, :create]

  def notification
    result = Transaction.finish(request.headers, params)
    render json: result
  end

  def success
    @transaction = Transaction.find_by_token(params[:token])
    TransactionMailer.completed_payment(@transaction).deliver if @transaction
  end

  def new
    authorize! :create, Transaction
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.begin current_user.id, @ticket_types, formatted_nested_data
    authorize! :create, @transaction

    if @transaction.errors.any?
      render action: "new"

    else
      puntopagos_response = @transaction.create_puntopagos_transaction

      if puntopagos_response.success?
        redirect_to puntopagos_response.payment_process_url

      else
        render action: "new"
      end
    end
  end

  def show
    @transaction = Transaction.find(params[:id])
    authorize! :read, @transaction
  end

  private

    def load_ticket_types
      @ticket_types = params[:ticket_types].values rescue nil
      @ticket_types = params[:ticket_types] if @ticket_types.nil?
    end

    def load_nested_attributes
      @event = Event.find(@ticket_types.first[:event_id])
      @nested_attributes = @event.nested_attributes
    end

    def formatted_nested_data
      nested_resource_attrs = params[:transaction][:nested_resource_attributes] rescue nil
      return {attrs: nested_resource_attrs,
        required_attributes: @event.required_nested_attributes
      } if nested_resource_attrs
    end
end
