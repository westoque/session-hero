class Manage::SessionVersionsController < Manage::BaseController
  def restore
    version = SubmissionVersion.find(params[:id])
    submission = version.submission
    return head(:forbidden) unless submission.event_id == @event.id
    submission.snapshot!(current_user)
    submission.update(title: version.title, abstract: version.abstract)
    redirect_to event_manage_submission_path(@event, submission), notice: "Restored version from #{fmt_datetime(version.created_at)}."
  end

  private

  def fmt_datetime(dt) = view_context.fmt_datetime(dt)
end
