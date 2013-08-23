class TicketsController < InheritedResources::Base
	load_and_authorize_resource

  def show
    super do |format|
      format.html
      format.pdf do
        render pdf: "ticket",
          template: "tickets/show",
          layout: "tickets/pdf",
          handlers: ["html.haml"],
          # renders html version if you set debug=true in URL
          show_as_html: params[:debug].present?
      end
    end
  end

  protected
    def collection
      @tickets = current_user.tickets
    end

end
