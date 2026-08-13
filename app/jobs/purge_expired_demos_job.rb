# Reaps expired demo sandboxes (events first so their graph cascades, then the
# throwaway users). Scheduled every 10 minutes via config/recurring.yml.
class PurgeExpiredDemosJob < ApplicationJob
  queue_as :default

  def perform
    now = Time.current

    Event.demo.where(demo_expires_at: ..now).find_each do |event|
      event.destroy!
    rescue => e
      Rails.logger.warn("[demo] failed to purge event #{event.id}: #{e.class}: #{e.message}")
    end

    User.demo.where(demo_expires_at: ..now).find_each do |user|
      user.destroy!
    rescue => e
      Rails.logger.warn("[demo] failed to purge user #{user.id}: #{e.class}: #{e.message}")
    end
  end
end
