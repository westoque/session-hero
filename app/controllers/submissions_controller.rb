class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_submission, only: %i[show edit update]

  # Speaker front-of-house: always scoped to the current user's own submissions.
  def index
    @submissions = current_user.submissions.where(event: @event).order(created_at: :desc)
  end

  def show; end

  def edit
    @locked = cfp_locked?
  end

  def update
    if cfp_locked?
      redirect_to event_submission_path(@event, @submission),
        alert: "The call for papers has closed — this submission can no longer be edited. Contact the organizers for changes."
      return
    end
    @submission.snapshot!(current_user)
    if @submission.update(submission_params)
      redirect_to event_submissions_path(@event), notice: "Submission updated."
    else
      @locked = false
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Editing locks once the CFP close date passes (CFP-16).
  def cfp_locked? = !@event.cfp_open?

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  def set_submission
    @submission = current_user.submissions.where(event: @event).find(params[:id])
  end

  def submission_params
    params.require(:submission).permit(:title, :abstract, :talk_format, :track_id, :audience_level, :key_takeaway)
  end
end
