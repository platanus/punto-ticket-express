class Puntopagos::TransactionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:create, :notification, :error, :success, :crear, :procesar]

  def notification
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
    # converting Ruby hash to array
    @ticket_types = params.values
    # TODO:
    # render de la vista de forma no editable:
    # los tipos de tickets elegidos por el cliente, sus cantidades y el precio total (por tipo y en general)
    # con botón de pagar. Clic aquí con ajax, nos lleva al action create.
  end

  def create
    ### TEST DATA ###
    tt = Event.first.ticket_types
    params[:ticket_types] = [{:id => tt.first.id, :quantity => 2}, {:id => tt.last.id, :quantity => 5}]
    Transaction.configure "http://localhost:3000", "0PN5J17HBGZHT7ZZ3X82", "uV3F4YluFJax1cKnvbcGwgjvx4QpvB+leU8dUj2o" #TODO: Poner esto en un initializer
    ### TEST DATA ###
    @transaction = Transaction.begin User.first.id, params[:ticket_types] #change current_user.id
    authorize! :create, @transaction

    if @transaction.errors.any?
      render action: "new"

    else
      redirect_to @transaction.process_url
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
    render :text => "Redireccion a puntopagos.com"
  end
end
