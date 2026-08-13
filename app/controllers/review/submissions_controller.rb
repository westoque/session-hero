class Review::SubmissionsController < Review::BaseController
  before_action :load_submission_and_round

  def show
    @review = @round.reviews.find_or_initialize_by(submission: @submission, user: current_user)
    @criteria = @round.review_criteria
  end

  private

  # Resolve the submission + the round it's being reviewed in, and GUARD scoping:
  # the reviewer may only open submissions assigned to them (ABS-05). Guessing
  # another submission's URL is redirected back to the queue.
  def load_submission_and_round
    @submission = Submission.find_by(id: params[:id], event_id: @event.id)

    # Rounds (in this event) where this submission is assigned to the current user.
    rounds = @event.review_rounds.where(
      id: ReviewAssignment.where(submission_id: @submission&.id, user_id: current_user.id)
                          .select(:review_round_id)
    )

    @round =
      if params[:round].present?
        rounds.find_by(id: params[:round])
      else
        rounds.first
      end

    return if @submission && @round

    redirect_to event_review_root_path(@event),
                alert: "That submission isn't assigned to you."
  end
end
