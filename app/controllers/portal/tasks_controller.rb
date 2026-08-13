module Portal
  class TasksController < BaseController
    before_action :set_assignment, only: %i[show complete reopen]

    def index
      @assignments = TaskAssignment.where(event_speaker_id: speaker_ids)
                                   .includes(:portal_task, event_speaker: :event)
                                   .to_a
    end

    def show
      redirect_to portal_tasks_path
    end

    def complete
      @assignment.complete!
      redirect_back fallback_location: portal_tasks_path, notice: "Task marked complete."
    end

    def reopen
      @assignment.reopen!
      redirect_back fallback_location: portal_tasks_path, notice: "Task reopened."
    end

    private

    # params[:id] is a TaskAssignment id, scoped to the current speaker so no
    # one can flip another speaker's task.
    def set_assignment
      @assignment = TaskAssignment.where(event_speaker_id: speaker_ids).find_by(id: params[:id])
      redirect_to portal_tasks_path, alert: "Task not found." unless @assignment
    end
  end
end
