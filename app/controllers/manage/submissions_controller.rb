class Manage::SubmissionsController < Manage::BaseController
  before_action :set_submission, only: %i[show update]

  def index
    @submissions = @event.submissions.includes(:user, :speaker_profile).order(created_at: :desc)
  end

  def show; end

  def update
    if @submission.update(status: params.require(:submission).permit(:status)[:status])
      redirect_to event_manage_submissions_path(@event), notice: "Submission updated."
    else
      redirect_to event_manage_submissions_path(@event), alert: "Could not update submission."
    end
  end

  private

  def set_submission
    @submission = @event.submissions.find(params[:id])
  end
end
