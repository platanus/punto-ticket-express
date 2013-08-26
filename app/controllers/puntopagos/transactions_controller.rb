class Puntopagos::TransactionsController < ApplicationController
  def notification
    # TODO:
    # Aquí puntopagos me hace un post avisando sobre el estado del pago.
    # Validar la firma del mensaje. Etonces:
    # Si hay error en la firma devolver json con: respuesta = 99 y token
    # (buscar transaction por token y ponerlo en :completed)
    # Si no hay error en la firma devolver json con: respuesta = 00 y token
    # (buscar transaction por token y ponerlo en :inactive)
    # Si esta todo bien, puntopagos redirigirá hacia mi success action sino a error action
    # TransactionMailer.completed_payment(Transaction.first).deliver (mandamos mail)
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
    params[:ticket_types] = [{:id => tt.first.id, :quantity => 3}, {:id => tt.last .id, :quantity => 5}]
    ### TEST DATA ###

    authorize! :create, Transaction
    @transaction = Transaction.begin current_user.id, params[:ticket_types]
    # Si no hay cupo o falla algo mas, redirigir a new mostrando errores
    # En el after create, ya con el ID, amount y transaction_datetime. hacer:
    # Net::HTTP.post_form a https://servidor/transaccion/crear
    # Si la respuesta es distinta a 00, hubo errores y debería hacer rollback de todo lo creado (tranacción, tickets)
    # (No se en que estado queda la transacción en puntopagos si devolvió error)
    # Si 00, devuelvo el <token>. Desde la vista se deberá redirigir a:
    # https://servidor/transaccion/procesar/<token>
  end

  def show
    authorize! :read, @transaction
  end
end
