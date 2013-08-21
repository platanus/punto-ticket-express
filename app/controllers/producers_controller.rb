class ProducersController < InheritedResources::Base
  load_and_authorize_resource

  protected
    def collection
      @producers = current_user.producers
    end
end
