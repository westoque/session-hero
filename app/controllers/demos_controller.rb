# Public "See demo": provisions an isolated, fully-populated demo event owned by
# a throwaway user, signs the visitor in, and drops them in the organizer
# console. The sandbox self-expires and is reaped by PurgeExpiredDemosJob.
class DemosController < ApplicationController
  def create
    result = DemoEnvironment.provision!
    sign_in(result[:organizer])
    redirect_to event_manage_root_path(result[:event]),
      notice: "Welcome to the SessionHero demo — click around freely. This sandbox is yours and resets automatically."
  rescue => e
    Rails.logger.error("[demo] provisioning failed: #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Sorry — we couldn't start a demo just now. Please try again in a moment."
  end
end
