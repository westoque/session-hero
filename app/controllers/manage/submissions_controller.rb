class Manage::SubmissionsController < Manage::BaseController
  before_action :set_submission, only: %i[show update edit decide convert]

  def index
    @submissions = @event.submissions.includes(:user, :event_speaker, :track, :room, :participants).order(created_at: :desc)
    @submissions = @submissions.where(status: params[:status]) if params[:status].present?
    if params[:q].present?
      @submissions = @submissions.where("title LIKE :q OR abstract LIKE :q", q: "%#{params[:q]}%")
    end
    @counts = @event.submissions.group(:status).count
  end

  def show
    @rounds = @event.review_rounds
    @versions = @submission.submission_versions.limit(20)
  end

  # Manual session creation (organizer adds a session directly).
  def new
    @submission = @event.submissions.new(status: "accepted", content_status: "in_review")
  end

  def create
    @submission = @event.submissions.new(create_params)
    @submission.user = current_user
    link_primary_speaker(@submission)
    if @submission.save
      redirect_to event_manage_submission_path(@event, @submission), notice: "Session created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @submission.snapshot!(current_user) if title_or_abstract_changing?
    if @submission.update(edit_params)
      redirect_to event_manage_submission_path(@event, @submission), notice: "Session updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Accept / reject / waitlist a single submission (status is a decision, no auto-email).
  def decide
    @submission.update(status: params[:status])
    @submission.update(content_status: "in_review") if @submission.accepted? && @submission.content_status == "draft"
    redirect_back fallback_location: event_manage_submissions_path(@event), notice: "Marked #{params[:status].to_s.humanize}."
  end

  # Bulk decision on multiple selected rows.
  def bulk_status
    ids = Array(params[:submission_ids]).reject(&:blank?)
    @event.submissions.where(id: ids).find_each { |s| s.update(status: params[:status]) }
    redirect_to event_manage_submissions_path(@event), notice: "Updated #{ids.size} session(s) to #{params[:status].to_s.humanize}."
  end

  # Handoff: turn an accepted submission into a scheduled session (idempotent).
  def convert
    @submission.update(status: "accepted") unless @submission.accepted?
    @submission.update(content_status: "in_review") if @submission.content_status == "draft"
    redirect_to event_manage_agenda_path(@event), notice: "“#{@submission.title}” is ready to schedule on the agenda."
  end

  private

  def set_submission = @submission = @event.submissions.find(params[:id])

  def title_or_abstract_changing?
    (params.dig(:submission, :title).present? && params[:submission][:title] != @submission.title) ||
      (params.dig(:submission, :abstract).present? && params[:submission][:abstract] != @submission.abstract)
  end

  def link_primary_speaker(sub)
    if params[:speaker_id].present? && (sp = @event.event_speakers.find_by(id: params[:speaker_id]))
      sub.event_speaker = sp
      sub.session_participants.build(event_speaker: sp, role: "Speaker")
    elsif params[:speaker_name].present?
      sp = @event.event_speakers.create!(name: params[:speaker_name], email: params[:speaker_email], status: "confirmed")
      sub.event_speaker = sp
      sub.session_participants.build(event_speaker: sp, role: "Speaker")
    end
  end

  def create_params
    params.require(:submission).permit(:title, :abstract, :talk_format, :track_id, :room_id,
      :audience_level, :key_takeaway, :status, :content_status)
  end

  def edit_params
    params.require(:submission).permit(:title, :abstract, :talk_format, :track_id, :room_id,
      :audience_level, :key_takeaway, :status, :content_status, :public_visible, :starts_at, :ends_at)
  end
end
