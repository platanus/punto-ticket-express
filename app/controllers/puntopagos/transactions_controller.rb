class Puntopagos::TransactionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:notification, :error, :success]
  before_filter :load_ticket_types, :only => [:new, :create]
  before_filter :load_event, :only => [:new, :create]

  SUCCESS_CODE = "00"
  ERROR_CODE = "99"

  def notification
    notification = PuntoPagos::Notification.new
    transaction = Transaction.finish(params[:token])

    if notification.valid?(request.headers, params) and !transaction.with_errors?
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
    @payment_mehtod = params[:transaction][:payment_method]
    @valid_promotion_code = params[:promotion_code]

    data = {}
    transaction_data = formatted_nested_data
    data[:transaction_nested_resource] = transaction_data if transaction_data
    tickets_data = formatted_tickets_data
    data[:tickets_nested_resources] = tickets_data if tickets_data
    promotions_data = formatted_promotions_data
    data[:promotions] = promotions_data if promotions_data

    @transaction = Transaction.begin current_user.id, @ticket_types, data
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

    render action: "puntopagos_conn_error"
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
      resp = request.create(transaction.id.to_s, transaction.total_amount_to_s, @payment_method)
      transaction.update_attribute(:token, resp.get_token) if resp.success?
      resp
    end

    def load_ticket_types
      @ticket_types = []
      types = params[:ticket_types]
      return unless types
      types.each do |id, data|
        qty = data['bought_quantity'].to_i
        next if qty.zero?
        tt = TicketType.find(id)
        tt.bought_quantity = qty
        @ticket_types << tt
      end
    end

    def load_event
      @event = Event.find(@ticket_types.first[:event_id])
    end

    def formatted_promotions_data
      promos = params[:promotions]
      return nil unless promos
      ticket_types_promotions = []
      promos.each do |ticket_type_id, promotion_id|
        promo = Promotion.find(promotion_id)
        tt = TicketType.find(ticket_type_id)
        promo.validation_code = @valid_promotion_code
        ticket_types_promotions << {ticket_type_id: tt.id, promotion: promo}
      end
      ticket_types_promotions
    end

    def formatted_tickets_data
      # TODO: Devolver un array con la información cargada en el formulario para cada uno de los tickets
      nil
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
          handlers: ["erb"])

        pdf_name = "tickets.pdf"
        pdf_path = Rails.root.join(dir, pdf_name)
        File.open(pdf_path, 'wb'){ |file| file << pdf }

        TransactionMailer.completed_payment(transaction, pdf_path, pdf_name).deliver
      end if transaction
    end
end
