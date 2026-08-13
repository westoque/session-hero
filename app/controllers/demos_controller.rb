# Public "See demo": provisions an isolated, fully-populated demo event owned by
# a throwaway user, signs the visitor in, and drops them in the organizer
# console. The sandbox self-expires and is reaped by PurgeExpiredDemosJob.
#
# Abuse protection (the endpoint is public and each call writes a rich event):
#   1. Session reuse — already in a demo? go back to it, don't create another.
#   2. Per-IP rate limit — a few new demos per IP per hour.
#   3. Global cap — hard ceiling on live demos so a flood can't exhaust the box.
class DemosController < ApplicationController
  MAX_ACTIVE_DEMOS = 50      # global ceiling on concurrent demo sandboxes
  PER_IP_HOURLY    = 5       # new demos allowed per IP per hour

  def create
    # 1. Already exploring a demo in this browser? Reuse it — no new sandbox.
    if current_user&.demo?
      existing = current_user.organizing_events.first
      return redirect_to event_manage_root_path(existing) if existing
      sign_out(current_user) # their demo was reaped; let them start fresh
    elsif user_signed_in?
      # A real signed-in user doesn't need a throwaway demo (don't sign them out).
      return redirect_to dashboard_path, notice: "You're already signed in."
    end

    # 2. Per-IP rate limit.
    if demo_rate_limited?
      return redirect_to root_path,
        alert: "You've started several demos already — please wait a bit before starting another."
    end

    # 3. Global capacity guard (protects the server regardless of source IP).
    if Event.demo.count >= MAX_ACTIVE_DEMOS
      return redirect_to root_path,
        alert: "Our live demo is at capacity right now — please try again in a few minutes."
    end

    result = DemoEnvironment.provision!
    sign_in(result[:organizer])
    redirect_to event_manage_root_path(result[:event]),
      notice: "Welcome to the SessionHero demo — click around freely. This sandbox is yours and resets automatically."
  rescue => e
    Rails.logger.error("[demo] provisioning failed: #{e.class}: #{e.message}")
    redirect_to root_path, alert: "Sorry — we couldn't start a demo just now. Please try again in a moment."
  end

  private

  # Sliding hourly window per client IP, backed by Rails.cache (Solid Cache in
  # production). remote_ip is the real client IP (kamal-proxy sets X-Forwarded-For).
  def demo_rate_limited?
    key = "demo:ip:#{request.remote_ip}"
    count = Rails.cache.read(key).to_i
    return true if count >= PER_IP_HOURLY
    Rails.cache.write(key, count + 1, expires_in: 1.hour)
    false
  end
end
