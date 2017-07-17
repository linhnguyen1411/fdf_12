class V1::EventsController < V1::BaseController

  def index
    events = current_user.events.by_date
    response_list events, EventSerializer, t("common.no_notifications")
  end
end
