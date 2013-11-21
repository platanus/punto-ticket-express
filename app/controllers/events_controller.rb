require 'chronic'

class EventsController < ApplicationController
  load_and_authorize_resource
  skip_filter :authenticate_user!, only: :show

  def my_index
    @events = current_user.events

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def participants
    @event = Event.find(params[:id])
    @transactions = @event.transactions.
      completed.joins([:nested_resource]).
      paginate(:page => params[:page], :per_page => 15)

    respond_to do |format|
      format.html
      format.xls do
        file_path = PTE::Event::Xls.generate_participants_book(@event)
        send_file file_path, :type => "application/excel"
      end
      format.json { render json: event.users }
    end
  end

  # GET /events/1
  # GET /events/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/new
  # GET /events/new.json
  def new
    @event = Event.new
    @attributes = NestedResource.nested_attributes

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  def sold_tickets
    @event = Event.find(params[:id])
    render "events/statistics/sold_tickets"
  end

  # GET /events/1/edit
  def edit
  end

  def data_to_collect
    array = NestedResource.nested_attributes + @event.nested_attributes
    @attributes = (array).group_by { |h|
      h[:attr] }.map { |k, v| v.reduce(:merge) }
  end

  # POST /events
  # POST /events.json
  def create
    # publishing or saving
    params[:event][:is_published] = params[:publish] ? true : false

    # prepare event params
    # parsing dates and times from Javascript to Rails
    params[:event][:start_time] = Chronic.parse "#{params[:start_date]} #{params[:start_time]}"
    params[:event][:end_time] = Chronic.parse "#{params[:end_date]} #{params[:end_time]}"

    # creates the object and reference the current user
    @event = current_user.events.build(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to event_path(@event), notice: I18n.t("controller.messages.create_success") }
        format.json { render json: @event, status: :created, location: @event }
      else
        @attributes = NestedResource.nested_attributes;
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    # publishing or saving
    params[:event][:is_published] = true if params.has_key? :publish

    # prepare event params
    # parsing dates and times from Javascript to Rails
    params[:event][:start_time] = Chronic.parse "#{params[:start_date]} #{params[:start_time]}"
    params[:event][:end_time] = Chronic.parse "#{params[:end_date]} #{params[:end_time]}"

    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])

        format.html {
          if @event.is_published
            redirect_to @event, notice: I18n.t("controller.messages.create_success")

          else
            redirect_to edit_event_path, notice: I18n.t("controller.messages.update_success")
          end
        }

        format.json { head :no_content }
      else
        format.html { render action: "edit", :alert => "Something serious happened"  }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.json
  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url }
      format.json { head :no_content }
    end
  end
end
