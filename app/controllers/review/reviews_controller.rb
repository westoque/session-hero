class Review::ReviewsController < Review::BaseController
  before_action :load_submission_and_round

  def create  = save_review
  def update  = save_review

  private

  # Same scoping guard as the submission screen: a reviewer can only submit a
  # review for a submission assigned to them, in a round they're assigned in.
  def load_submission_and_round
    @submission = Submission.find_by(id: params[:submission_id], event_id: @event.id)

    rounds = @event.review_rounds.where(
      id: ReviewAssignment.where(submission_id: @submission&.id, user_id: current_user.id)
                          .select(:review_round_id)
    )
    @round = params[:round].present? ? rounds.find_by(id: params[:round]) : rounds.first

    return if @submission && @round

    redirect_to event_review_root_path(@event),
                alert: "That submission isn't assigned to you."
  end

  def save_review
    review = @round.reviews.find_or_initialize_by(submission: @submission, user: current_user)

    review.comment      = params.dig(:review, :comment)
    review.coi          = coi_param
    review.scores       = scores_param
    review.status       = "completed"
    review.submitted_at = Time.current

    if review.save
      redirect_to event_review_submission_path(@event, @submission, round: @round.id),
                  notice: "Review submitted."
    else
      redirect_to event_review_submission_path(@event, @submission, round: @round.id),
                  alert: "Could not save your review."
    end
  end

  def coi_param
    ActiveModel::Type::Boolean.new.cast(params.dig(:review, :coi))
  end

  # Build the scores hash keyed by criterion id (as string) → submitted value,
  # keeping only criteria that belong to this round.
  def scores_param
    submitted = params[:scores]&.to_unsafe_h || {}
    ids = @round.review_criteria.pluck(:id).map(&:to_s)
    submitted.slice(*ids).transform_values(&:to_s)
  end
end
