class V1::EventsController < V1::BaseController
  skip_before_filter :verify_authenticity_token, only: :update

  def index
    events = current_user.events.by_date
    response_list events, EventSerializer, t("common.no_notifications")
  end

  def update
    if params[:read_all].present?
      current_user.events.unread.update_all read: true
      response_success t "api.success"
    else
      update_event_of_user
    end
  end

  private

  def update_event_of_user
    event = Event.find_by id: params[:id]
    if event.present? && event.of_user?(current_user)
      event.update read: true
      response_success t "api.success"
    else
      response_not_found t "api.not_found"
    end
  end
end
