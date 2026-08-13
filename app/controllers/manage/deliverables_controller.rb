class Manage::DeliverablesController < Manage::BaseController
  before_action :set_deliverable, only: %i[show approve comment]

  # Deliverables dashboard + central files library in one screen.
  def index
    @tasks = @event.portal_tasks.includes(task_assignments: :event_speaker)
    @file_tasks = @tasks.select(&:file_request?)
    @speakers = @event.event_speakers
    @deliverables = @event.submissions.flat_map(&:deliverables).select { |d| d.file_versions.any? }
    @filter = params[:filter]
    @rows = task_status_rows
    @rows = @rows.reject { |r| r[:completed] } if @filter == "incomplete"
    @rows = @rows.select { |r| r[:completed] } if @filter == "complete"
  end

  def show
    @versions = @deliverable.file_versions.order(:version_number)
    @comments = @deliverable.file_comments
  end

  # Approve the session this deliverable belongs to (gates public visibility).
  def approve
    @deliverable.submission&.update(content_status: params[:status].presence || "approved")
    redirect_back fallback_location: event_manage_deliverable_path(@event, @deliverable), notice: "Content marked #{(params[:status] || 'approved').humanize}."
  end

  def comment
    @deliverable.file_comments.create(user: current_user, author_name: "#{current_user.display_name} (Organizer)", body: params[:body])
    redirect_to event_manage_deliverable_path(@event, @deliverable), notice: "Comment posted."
  end

  def bulk_download
    ids = Array(params[:deliverable_ids]).reject(&:blank?)
    redirect_to event_manage_deliverables_path(@event),
      notice: "Preparing a ZIP of the latest version of #{ids.size} file(s)… it will download when ready."
  end

  def bulk_remind
    outstanding = task_status_rows.reject { |r| r[:completed] }.select { |r| r[:task].file_request? }
    speakers = outstanding.map { |r| r[:speaker] }.uniq
    speakers.each do |sp|
      next if sp.email.blank?
      log = @event.communication_logs.create!(user: current_user,
        subject: "Reminder: outstanding deliverables for #{@event.name}",
        body: "Hi #{sp.name}, you still have outstanding uploads. Please complete them before the deadline.",
        recipients: [{ "name" => sp.name, "email" => sp.email }], sent_at: Time.current)
      EventMailer.generic(sp.email, log.subject, log.body).deliver_later rescue nil
    end
    redirect_to event_manage_deliverables_path(@event, filter: "incomplete"),
      notice: "Reminder sent to #{speakers.size} speaker(s) with outstanding deliverables."
  end

  private

  def set_deliverable
    @deliverable = Deliverable.joins(:submission).where(submissions: { event_id: @event.id }).find(params[:id])
  end

  def task_status_rows
    rows = []
    @event.portal_tasks.each do |task|
      task.task_assignments.includes(:event_speaker).each do |ta|
        rows << { task: task, speaker: ta.event_speaker, assignment: ta, completed: ta.completed?, due_on: task.due_on }
      end
    end
    rows
  end
end
