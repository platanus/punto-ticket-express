class ProducersController < ApplicationController
  load_and_authorize_resource

  def new
    @producer = Producer.new

    respond_to do |format|
      format.html
      format.json { render json: @producer }
    end
  end

  def edit
    @producer = Producer.find(params[:id])
  end

  def create
    @producer = Producer.new(params[:producer])
    @producer.users << current_user

    respond_to do |format|
      if @producer.save
        format.html { redirect_to configuration_producers_path, notice: I18n.t("controller.messages.create_success") }
        format.json { render json: @producer, status: :created, location: @producer }

      else
        format.html { render action: "new" }
        format.json { render json: @producer.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @producer = Producer.find(params[:id])

    respond_to do |format|
      if @producer.update_attributes(params[:producer])
        format.html { redirect_to configuration_producers_path, notice: I18n.t("controller.messages.update_success") }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @producer.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @producer.destroy

    respond_to do |format|
      format.html { redirect_to configuration_producers_url }
      format.json { head :no_content }
    end
  end
end

