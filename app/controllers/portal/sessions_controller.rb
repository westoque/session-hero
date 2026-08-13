module Portal
  class SessionsController < BaseController
    before_action :set_session, only: %i[show]

    def index
      @sessions = my_sessions_scope.includes(:track, :room, :event).to_a
    end

    def show
      @deliverables = @session.deliverables
                              .where(event_speaker_id: speaker_ids)
                              .includes(:portal_task, :file_versions, :file_comments)
                              .to_a
      # File-request tasks for this speaker on this event that still need an upload.
      @file_tasks = TaskAssignment.where(event_speaker_id: speaker_ids)
                                  .includes(:portal_task)
                                  .select { |a| a.portal_task.file_request? && a.portal_task.event_id == @session.event_id }
    end

    private

    # Scope to the current user's own sessions. Requesting anyone else's id
    # bounces back to the index with an alert (CNT-03).
    def set_session
      @session = my_sessions_scope.find_by(id: params[:id])
      return if @session
      redirect_to portal_sessions_path, alert: "That session isn't on your schedule."
    end
  end
end
