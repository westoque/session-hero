class DashboardController < ApplicationController
  before_action :authenticate_user!

  # One unified home. We group the user's events by the hat they wear, but there's
  # no "log in as organizer vs speaker" — role is resolved per event, right here.
  def index
    @organizing = current_user.organizing_events.order(updated_at: :desc)
    @speaking   = current_user.speaking_events.order(updated_at: :desc)
  end
end
