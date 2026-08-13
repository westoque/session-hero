class Review::BaseController < ApplicationController
  layout "review"
  before_action :authenticate_user!
  before_action :set_event
  before_action :require_reviewer_access!

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  # Reviewer access is granted by a reviewer EventMembership on this event OR by
  # holding any ReviewAssignment in one of the event's rounds. No organizer/admin
  # role is implied or required here (CFP-10).
  def require_reviewer_access!
    return if current_user.reviewer_of?(@event)
    return if reviewer_assignments.exists?

    redirect_to root_path, alert: "You don't have reviewer access to this event."
  end

  # Every assignment for the current reviewer across this event's rounds.
  def reviewer_assignments
    ReviewAssignment
      .joins(:review_round)
      .where(review_rounds: { event_id: @event.id }, user_id: current_user.id)
  end

  # Rounds this reviewer actually has assignments in, in display order.
  def assigned_rounds
    @event.review_rounds
          .where(id: reviewer_assignments.select(:review_round_id))
  end
end
