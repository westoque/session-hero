module Portal
  class DashboardController < BaseController
    def index
      @sessions = my_sessions_scope.includes(:track, :room).to_a
      @assignments = TaskAssignment.where(event_speaker_id: speaker_ids)
                                   .includes(:portal_task).to_a
      @tasks_total = @assignments.size
      @tasks_done = @assignments.count(&:completed?)
      # Pending session invitations across the speaker's roster rows.
      @invitations = current_speakers.select { |s| s.status == "invited" }
    end
  end
end
