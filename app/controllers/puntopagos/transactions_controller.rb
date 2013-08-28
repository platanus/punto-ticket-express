class Puntopagos::TransactionsController < ApplicationController
  before_filter :load_notification_attrs, only: [:notification]
  before_filter :authenticate_user!, :except => [:create, :notification, :error, :success, :crear, :procesar, :send_notification]

  def notification
    transaction = Transaction.find_by_id params[:trx_id]
    transaction.finish request.header['Autorizacion'], @notification_attrs
    # TODO:
    # Aquí puntopagos me hace un post avisando sobre el estado del pago.
    # Validar la firma del mensaje. Etonces:
    # Si hay error en la firma devolver json con: respuesta = 99 y token
    # (buscar transaction por token y ponerlo en :completed)
    # Si no hay error en la firma devolver json con: respuesta = 00 y token
    # (buscar transaction por token y ponerlo en :inactive)
    # Si esta todo bien, puntopagos redirigirá hacia mi success action sino a error action
    # TransactionMailer.completed_payment(Transaction.first).deliver
  end

  def error
    # TODO: mensaje de error al cliente
  end

  def success
    # TODO: mensaje de éxito al cliente
  end

  def new
    authorize! :create, Transaction
    @transaction = Transaction.new
    # TODO:
    # render de la vista de forma no editable:
    # los tipos de tickets elegidos por el cliente, sus cantidades y el precio total (por tipo y en general)
    # con botón de pagar. Clic aquí con ajax, nos lleva al action create.
  end

  def create
    ### TEST DATA ###
    tt = Event.first.ticket_types
    params[:ticket_types] = [{:id => tt.first.id, :quantity => 2}, {:id => tt.last.id, :quantity => 5}]
    Transaction.configure "http://localhost:3001", "0PN5J17HBGZHT7ZZ3X82", "uV3F4YluFJax1cKnvbcGwgjvx4QpvB+leU8dUj2o" #TODO: Poner esto en un initializer
    ### TEST DATA ###
    @transaction = Transaction.begin User.first.id, params[:ticket_types] #change current_user.id
    authorize! :create, @transaction

    if @transaction.errors.any?
      render action: "new"

    else
      redirect_to @transaction.process_url + "?trx_id=#{@transaction.id}&amount=#{@transaction.total_amount_to_s}&transaction_date=#{@transaction.RFC1123_date}"
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

  def procesar

  end

  def send_notification
    options = {}
    url = "http://localhost:3000/puntopagos/transactions/notification"
    message = "#{url}\n" +
    "#{params[:trx_id]}\n" +
    "#{params[:monto]}\n" +
    "#{params[:transaction_date]}"
    signed_message = Digest::HMAC.hexdigest(message, "uV3F4YluFJax1cKnvbcGwgjvx4QpvB", Digest::SHA1)
    auth = "PP0PN5J17HBGZHT7ZZ3X82:#{signed_message}"

    options[:headers] = {"Fecha" => params[:transaction_date], "Autorizacion" => auth}
    options[:body] = params
    response = HTTParty.post(url, options)

    render :text => "Notificacion enviada"
  end

  private

    def self.load_notification_attrs
      @notification_attrs = {}
      @notification_attrs[:id] = params[:trx_id] if params.has_key? :trx_id
      @notification_attrs[:token] = params[:token] if params.has_key? :token
      @notification_attrs[:amount] = params[:monto] if params.has_key? :monto
      @notification_attrs[:payment_method] = params[:medio_pago] if params.has_key? :medio_pago
      @notification_attrs[:approbation_date] = params[:fecha_aprobacion] if params.has_key? :fecha_aprobacion
    end
end
