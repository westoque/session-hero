module Portal
  class BaseController < ApplicationController
    layout "portal"
    before_action :authenticate_user!
    before_action :require_speaker!

    helper_method :current_speakers, :portal_events, :my_sessions_scope, :speaker_ids

    private

    # The current user's roster identity across every event they appear in.
    # Everything in the portal is scoped through this — never expose another
    # speaker's data.
    def current_speakers
      @current_speakers ||= current_user.event_speakers.to_a
    end

    def portal_events
      @portal_events ||= current_user.portal_events.to_a
    end

    def speaker_ids
      current_speakers.map(&:id)
    end

    # A speaker's own sessions: submissions they participate in.
    def my_sessions_scope
      Submission.joins(:session_participants)
                .where(session_participants: { event_speaker_id: speaker_ids })
                .distinct
    end

    def require_speaker!
      return if current_speakers.any?
      redirect_to root_path, alert: "You don't have a speaker portal yet."
    end
  end
end
