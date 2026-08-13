module Portal
  class DeliverablesController < BaseController
    before_action :set_session
    before_action :set_deliverable, only: %i[add_version]

    def create
      unless params[:file].present?
        return redirect_to portal_session_path(@session), alert: "Choose a file to upload."
      end

      speaker = primary_speaker_for(@session)
      task = resolved_portal_task
      deliverable = @session.deliverables.create!(
        event_speaker: speaker,
        portal_task: task,
        title: deliverable_params[:title].presence || default_title(task),
        kind: allowed_kind(deliverable_params[:kind])
      )
      deliverable.add_version!(params[:file])

      # Uploading against a file-request task satisfies it.
      complete_assignment_for(task, speaker)

      redirect_to portal_session_path(@session), notice: "File uploaded."
    end

    def add_version
      unless params[:file].present?
        return redirect_to portal_session_path(@session), alert: "Choose a file to upload."
      end
      @deliverable.add_version!(params[:file])
      redirect_to portal_session_path(@session), notice: "New version uploaded."
    end

    private

    def set_session
      @session = my_sessions_scope.find_by(id: params[:session_id])
      redirect_to portal_sessions_path, alert: "That session isn't on your schedule." unless @session
    end

    # Only deliverables belonging to this speaker on this session.
    def set_deliverable
      @deliverable = @session.deliverables.where(event_speaker_id: speaker_ids).find_by(id: params[:id])
      redirect_to portal_session_path(@session), alert: "File not found." unless @deliverable
    end

    def deliverable_params
      (params[:deliverable] || {}).permit(:title, :kind, :portal_task_id)
    end

    def primary_speaker_for(session)
      ids = speaker_ids
      session.participants.detect { |p| ids.include?(p.id) } || current_speakers.first
    end

    def resolved_portal_task
      tid = deliverable_params[:portal_task_id]
      return nil if tid.blank?
      # Only tasks assigned to this speaker on this event are addressable.
      PortalTask.where(event_id: @session.event_id)
                .where(id: TaskAssignment.where(event_speaker_id: speaker_ids).select(:portal_task_id))
                .find_by(id: tid)
    end

    def complete_assignment_for(task, speaker)
      return unless task
      assignment = TaskAssignment.where(event_speaker_id: speaker_ids, portal_task_id: task.id).first
      assignment&.complete!
    end

    def allowed_kind(kind)
      Deliverable::KINDS.include?(kind) ? kind : "presentation"
    end

    def default_title(task)
      task&.title.presence || "Session file"
    end
  end
end
