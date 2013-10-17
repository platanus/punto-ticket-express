class Puntopagos::TransactionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:notification, :error, :success]
  before_filter :load_ticket_types, :only => [:new, :create]
  before_filter :load_nested_attributes, :only => [:new, :create]

  SUCCESS_CODE = "00"
  ERROR_CODE = "99"

  def notification
    notification = PuntoPagos::Notification.new
    transaction = Transaction.finish(params[:token])

    if notification.valid?(request.headers, params) and transaction.valid?
       render json: {
        respuesta: SUCCESS_CODE,
        token: params[:token]}

    else
      render json: {
        respuesta: ERROR_CODE,
        error: transaction.error,
        token: params[:token]}
    end
  end

  def success
    @transaction = Transaction.find_by_token(params[:token])
    send_completed_payment_mail @transaction
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
      return
    end

    puntopagos_response = create_puntopagos_transaction(@transaction)

    if puntopagos_response.success?
      redirect_to puntopagos_response.payment_process_url
      return
    end

    render action: "new"
  end

  def show
    @transaction = Transaction.find(params[:id])
    authorize! :read, @transaction
  end

  def nested_resource
    @transaction = Transaction.find(params[:id])
    authorize! :read, @transaction
    @nested_resource = @transaction.nested_resource
    @event = @transaction.event
  end

  private

    def create_puntopagos_transaction transaction
      request = PuntoPagos::Request.new
      resp = request.create(transaction.id.to_s, transaction.total_amount_to_s)
      transaction.update_attribute(:token, resp.get_token) if resp.success?
      resp
    end

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

    def send_completed_payment_mail transaction
      Dir.mktmpdir do |dir|
        @tickets = transaction.tickets

        pdf = render_to_string(
          pdf: "ticket",
          template: "tickets/pdf",
          layout: "tickets/pdf",
          handlers: ["haml"])

        pdf_name = "tickets.pdf"
        pdf_path = Rails.root.join(dir, pdf_name)
        File.open(pdf_path, 'wb'){ |file| file << pdf }

        TransactionMailer.completed_payment(transaction, pdf_path, pdf_name).deliver
      end if transaction
    end
end
