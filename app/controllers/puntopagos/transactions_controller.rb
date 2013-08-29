class Puntopagos::TransactionsController < ApplicationController
  before_filter :load_notification_attrs, only: [:notification]
  before_filter :authenticate_user!, :except => [:create, :notification, :error, :success, :crear, :procesar, :send_notification]

  def notification
    unless params.has_key? :token
      head :bad_request
      return
    end

    result = Transaction.finish(params[:token],
      request.headers["Autorizacion"],
      @notification_attrs)

    render json: result
  end

  def new
    authorize! :create, Transaction
    @transaction = Transaction.new
  end

  def create
    ### TEST DATA ###
    tt = Event.first.ticket_types
    params[:ticket_types] = [{:id => tt.first.id, :quantity => 2}, {:id => tt.last.id, :quantity => 5}]
    Transaction.configure "http://localhost:3001", "0PN5J17HBGZHT7ZZ3X82", "uV3F4YluFJax1cKnvbcGwgjvx4Qpv" #TODO: Poner esto en un initializer
    ### TEST DATA ###
    @transaction = Transaction.begin User.first.id, params[:ticket_types] #change current_user.id
    authorize! :create, @transaction

    if @transaction.errors.any?
      render action: "new"

    else
      uri = Addressable::URI.parse(@transaction.process_url)
      uri.query_values = {
        :trx_id => @transaction.id,
        :amount => @transaction.total_amount_to_s,
        :transaction_date => @transaction.RFC1123_date,
      }

      redirect_to uri.to_s
      #TODO: remover los parámetros. Por ahora los paso para simular respuesta de Puntopagos
    end
  end

  def show
    authorize! :read, @transaction
  end

  #PUNTO PAGOS

  def crear
    render json: {
      "respuesta" => "00",
      "token" => Digest::MD5.hexdigest(params[:trx_id]),
      "trx_id" => params[:trx_id],
      "monto" => params[:monto]
    }, status: :created
  end

  def send_notification
    options = {}
    client_url = "http://localhost:3000/"
    message = "puntopagos/transactions/notificacion\n" +
    "#{params[:trx_id]}\n" +
    "#{params[:monto]}\n" +
    "#{params[:transaction_date]}"

    signed_message = Digest::HMAC.hexdigest(message, "uV3F4YluFJax1cKnvbcGwgjvx4QpvB", Digest::SHA1)
    auth = "PP0PN5J17HBGZHT7ZZ3X82:#{signed_message}"

    options[:headers] = {"Fecha" => params[:transaction_date], "Autorizacion" => auth}
    options[:body] = params
    response = HTTParty.post(client_url + "puntopagos/transactions/notification", options)
    body = response.parsed_response

    if body["respuesta"] == "00"
      redirect_to client_url + "puntopagos/transactions/success/" + body["token"]
    else
      redirect_to client_url + "puntopagos/transactions/error/" + body["token"]
    end
  end

  private

    def load_notification_attrs
      @notification_attrs = {}
      @notification_attrs[:id] = params[:trx_id] if params.has_key? :trx_id
      @notification_attrs[:amount] = params[:monto] if params.has_key? :monto
      @notification_attrs[:payment_method] = params[:medio_pago] if params.has_key? :medio_pago
      @notification_attrs[:approbation_date] = params[:fecha_aprobacion] if params.has_key? :fecha_aprobacion
    end
end
