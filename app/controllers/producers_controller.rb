class ProducersController < InheritedResources::Base
  load_and_authorize_resource

  def create
    @producer = Producer.new(params[:producer])
    @producer.users << current_user
    create!
  end

  protected
    def collection
      @producers = current_user.producers
    end
end
