class Manage::DashboardController < Manage::BaseController
  def index
    @submissions = @event.submissions.includes(:user, :speaker_profile).order(created_at: :desc)
  end
end
