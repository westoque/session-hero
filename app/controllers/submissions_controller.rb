class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_submission, only: %i[show edit update]

  # Speaker front-of-house: always scoped to the current user's own submissions.
  def index
    @submissions = current_user.submissions.where(event: @event).order(created_at: :desc)
  end

  def show; end

  def edit; end

  def update
    if @submission.update(submission_params)
      redirect_to event_submissions_path(@event), notice: "Submission updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  def set_submission
    @submission = current_user.submissions.where(event: @event).find(params[:id])
  end

  def submission_params
    params.require(:submission).permit(:title, :abstract, :talk_format)
  end
end
