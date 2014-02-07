class PromotionsController < ApplicationController
  before_filter :prepare_code_param, only: :create

  def new
    @event = Event.find_by_id params[:id]
    @promotion = Promotion.new
  end

  def create
    @event = Event.find_by_id(params[:id])
    @promotion = Promotion.new(params[:promotion])
    scope_id = params[:promotion][:promotable_id]

    if scope_id.blank?
      @promotion.promotable = @event

    else
      ticket_type = TicketType.find_by_id(scope_id)
      @promotion.promotable = ticket_type
    end

    authorize! :create, @promotion

    respond_to do |format|
      if @promotion.create_with_codes
        format.html { redirect_to promotions_url(@event), notice: I18n.t("controller.messages.create_success") }
        format.json { render json: @promotion, status: :created, location: @promotion }

      else
        load_codes_xls_errors
        format.html { render action: "new" }
        format.json { render json: @promotion.errors, status: :unprocessable_entity }
      end
    end
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
    authorize! :disable, @promotion
    @promotion.disable
    redirect_to promotions_url(id: @promotion.event.id)
  end

  private

    def load_codes_xls_errors
      if @promotion.errors.include?(:codes_file)
        flash[:error] = @promotion.errors[:codes_file].join(", ")
      end
    end

    def prepare_code_param
      params.delete :codes_file if params[:code_type] == 'single'
      params.delete :validation_code if params[:code_type] == 'multiple'
    end
end
