class PromotionsController < ApplicationController

  def index
    event = Event.find_by_id params[:id]
    authorize! :read_event_promotions, event
    # TODO: cambiar event.promotions por un método que traiga las
    # promociones aplicadas al evento y además, las promociones aplicadas a los tipos de evento del evento.
    @promotions = event.ticket_types.first.promotions
  end

  def new
    @promotion = Promotion.new
  end

  def create
    authorize! :create, Promotion
  end

  def show
    @promotion = Promotion.find_by_id params[:id]
    authorize! :read, @promotion
  end

  def enable
    @promotion = Promotion.find_by_id params[:id]
    authorize! :enable, @promotion
    redirect_to promotions_url(id: @promotion.event.id)
  end

  def disable
    @promotion = Promotion.find_by_id params[:id]
    authorize! :enable, @promotion
    redirect_to promotions_url(id: @promotion.event.id)
  end
end
