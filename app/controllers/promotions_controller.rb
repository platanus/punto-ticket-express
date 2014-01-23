class PromotionsController < ApplicationController

  def new
    @event = Event.find_by_id params[:id]
    @promotion = Promotion.new
  end

  def create
    @event = Event.find_by_id(params[:id])
    @promotion = Promotion.new(params[:promotion])
    scope_id = params[:promotion][:promotable_id].to_s

    if scope_id.empty?
      @promotion.promotable = @event

    else
      ticket_type = TicketType.find_by_id(scope_id)
      @promotion.promotable = ticket_type
    end

    authorize! :create, @promotion

    respond_to do |format|
      if @promotion.save
        format.html { redirect_to promotions_url(@event), notice: I18n.t("controller.messages.create_success") }
        format.json { render json: @promotion, status: :created, location: @promotion }

      else
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

  def new_codes_load
    @promotion = Promotion.find_by_id params[:id]
    authorize! :new_codes_load, @promotion
  end

  def upload_codes
    @promotion = Promotion.find_by_id params[:id]
    authorize! :upload_codes, @promotion
    response = PTE::Promotion::Xls.load_codes_into_promotion @promotion, params[:promotion][:xls_file]

    respond_to do |format|
      if response[:result] == :success
        format.html { redirect_to promotion_url(@promotion),
          notice: I18n.t("controller.messages.upload_success") }
      else
        @errors = response[:errors]
        format.html { render action: 'new_upload',
          alert: I18n.t("controller.messages.upload_error")   }
      end
    end
  end
end
