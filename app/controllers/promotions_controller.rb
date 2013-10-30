class PromotionsController < ApplicationController

  def index
    @event = Event.find_by_id params[:id]
    authorize! :read_event_promotions, @event
    @promotions = @event.all_promotions
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
    @event = @promotion.event
  end

  def enable
    @promotion = Promotion.find_by_id params[:id]
    authorize! :enable, @promotion
    @promotion.enable
    redirect_to promotions_url(id: @promotion.event.id)
  end

  def disable
    @promotion = Promotion.find_by_id params[:id]
    authorize! :enable, @promotion
    @promotion.disable
    redirect_to promotions_url(id: @promotion.event.id)
  end
end
