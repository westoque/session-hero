class Review::QueueController < Review::BaseController
  # The reviewer's dashboard: one section per round they're assigned in, each
  # listing ONLY the submissions assigned to them in that round (ABS-05).
  def index
    @rounds = assigned_rounds.to_a

    # Precompute per-round: the reviewer's assigned submissions and their reviews,
    # so the view stays free of query logic.
    @submissions_by_round = {}
    @reviews_by_round = {}
    @rounds.each do |round|
      subs = round.submissions_for(current_user).to_a
      @submissions_by_round[round.id] = subs
      @reviews_by_round[round.id] =
        round.reviews.where(user: current_user, submission_id: subs.map(&:id)).index_by(&:submission_id)
    end
  end
end
