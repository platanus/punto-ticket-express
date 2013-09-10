require 'chronic'

class EventsController < ApplicationController
  load_and_authorize_resource
  skip_filter :authenticate_user!, only: :show

  # GET /events
  # GET /events.json
  def index
    @events = current_user.events

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  def participants
    event = Event.find(params[:id])

    respond_to do |format|
      format.xls do
        file_path = PTE::Event::Xls.generate_participants_book(event,
          I18n.t("xls.participants.file_name"),
          I18n.t("xls.participants.zip_file_name"))

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

    @event.data_to_collect = [
      {:name => :email, :required => false},
      {:name => :name, :required => false},
      {:name => :age, :required => false},
      {:name => :rut, :required => false}
    ]

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @event }
    end
  end

  # GET /events/1/edit
  def edit
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

    # create data collection and remove nil data
    @event.data_to_collect = @event.data_to_collect.select.with_index{|data, i| !data[i.to_s].nil?}
    @event.data_to_collect = @event.data_to_collect.reduce([]) do |data, i|
      data << {:name => i[:attr].to_s, :required => !i.has_value?('optional')}
    end

    # @event.data_to_collect = [
    #   {:name => :email, :required => false},
    #   {:name => :name, :required => true},
    #   {:name => :age, :required => false},
    #   {:name => :rut, :required => true}
    # ]

    respond_to do |format|
      if @event.save
        format.html { redirect_to events_path, notice: 'Event was successfully created.' }
        format.json { render json: @event, status: :created, location: @event }
      else
        @attributes = params[:event][:data_to_collect];
        format.html { render action: "new" }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.json
  def update
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to @event, notice: 'Event was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
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
