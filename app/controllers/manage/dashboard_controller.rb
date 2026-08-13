class Manage::DashboardController < Manage::BaseController
  def index
    @submissions = @event.submissions.order(created_at: :desc)
    @counts = @event.submissions.group(:status).count
    @speaker_count = @event.event_speakers.count
    @rounds = @event.review_rounds
    @tasks = @event.portal_tasks
    @scheduled = @event.sessions.scheduled.count
  end
end
