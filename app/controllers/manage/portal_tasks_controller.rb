class Manage::PortalTasksController < Manage::BaseController
  before_action :set_task, only: %i[edit update destroy toggle]

  def index
    @tasks = @event.portal_tasks.includes(task_assignments: :event_speaker)
    @speakers = @event.event_speakers
  end

  def new = @task = @event.portal_tasks.new(due_on: @event.starts_on)
  def edit; end

  def create
    @task = @event.portal_tasks.new(task_params.except(:speaker_ids))
    if @task.save
      assign_speakers(@task, params.dig(:portal_task, :speaker_ids))
      redirect_to event_manage_portal_tasks_path(@event), notice: "Task created and assigned."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @task.update(task_params.except(:speaker_ids))
      assign_speakers(@task, params.dig(:portal_task, :speaker_ids)) if params.dig(:portal_task, :speaker_ids)
      redirect_to event_manage_portal_tasks_path(@event), notice: "Task updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    redirect_to event_manage_portal_tasks_path(@event), notice: "Task deleted."
  end

  # Organizer marks a task complete/incomplete on behalf of a speaker.
  def toggle
    ta = @task.task_assignments.find(params[:assignment_id])
    ta.completed? ? ta.reopen! : ta.complete!
    redirect_back fallback_location: event_manage_portal_tasks_path(@event)
  end

  private

  def set_task = @task = @event.portal_tasks.find(params[:id])

  def assign_speakers(task, ids)
    ids = Array(ids).reject(&:blank?)
    return if ids.empty?
    ids.each do |sid|
      sp = @event.event_speakers.find_by(id: sid)
      task.task_assignments.find_or_create_by!(event_speaker: sp) if sp
    end
  end

  def task_params
    params.require(:portal_task).permit(:title, :description, :due_on, :task_type, :required, :external_link, speaker_ids: [])
  end
end
