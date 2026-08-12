class Manage::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :require_organizer!

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  # Backstage is gated by an organizer membership FOR THIS EVENT — not a global
  # role. Being an organizer elsewhere grants nothing here.
  def require_organizer!
    return if current_user.organizer_of?(@event)
    redirect_to event_path(@event), alert: "You don't manage this event."
  end
end
