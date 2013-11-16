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
    load_ticket_resources_from_types
  end

  def create
    @payment_method = params[:transaction][:payment_method] rescue nil
    @valid_promotion_code = params[:promotion_code]

    data = {}
    transaction_data = params[:transaction][:nested_resource_attributes] rescue nil
    data[:transaction_nested_resource] = transaction_data if transaction_data
    tickets_data = formatted_nested_tickets_data
    data[:tickets_nested_resources] = tickets_data if tickets_data
    promotions_data = formatted_promotions_data
    data[:promotions] = promotions_data if promotions_data

    @transaction = Transaction.begin current_user.id, @ticket_types, data
    authorize! :create, @transaction

    if @transaction.errors.any?
      load_ticket_resources_from_transaction
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

    def load_ticket_resources_from_types
      if @event.require_ticket_resources?
        @ticket_resources = []
        @ticket_types.each do |tt|
          type = {id: tt.id, name: tt.name, nested_resources: []}
          tt.bought_quantity.times do
            type[:nested_resources] << @event.nested_attributes
          end
          @ticket_resources << type
        end
      end
    end

    def load_ticket_resources_from_transaction
      @ticket_resources = []
      resources = @transaction.tickets_nested_resources || []
      resources.each do |tt|
        ticket_type = TicketType.find(tt[:ticket_type_id])
        type = {id: ticket_type.id, name: ticket_type.name, nested_resources: []}
        tt[:resources].each do |resource_data|
          resource = []
          attrs = resource_data[:resource].keys

          attrs.each do |attr|
            item = {}

            @event.nested_attributes.each do |event_attr|
              if event_attr[:attr].to_s == attr.to_s
                item = event_attr
                break
              end
            end

            item[:value] = resource_data[:resource][attr]

            resource_data[:errors].keys.each do |attr_with_error|
              if attr_with_error.to_s == attr.to_s
                item[:errors] = resource_data[:errors][attr_with_error]
              end
            end

            resource << item
          end

          type[:nested_resources] << resource
        end

        @ticket_resources << type
      end
    end

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

    def formatted_nested_tickets_data
      data = params[:tickets_nested_resources]
      return nil unless data
      data.inject([]) do |result, ticket_type|
        type_data = {ticket_type_id: ticket_type.first,
          resources: ticket_type.last.values}
        result << type_data
      end
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
