class PublicSubmissionsController < ApplicationController
  # Public Call for Papers form — shareable link, no login required.
  before_action :set_event
  before_action :set_form

  def new
    @closed = @form.closed?
    @submission = load_draft || Submission.new
    @resuming = @submission.persisted?
    @prefill_email = current_user&.email || @submission.event_speaker&.email
  end

  def create
    return reject_closed if @form.closed?
    build_submission("submitted")

    if submitted_email.blank?
      flash.now[:alert] = "Please provide your email so we can reach you."
      @closed = false
      return render :new, status: :unprocessable_entity
    end

    if missing_required.any?
      flash.now[:alert] = "Please complete: #{missing_required.join(', ')}."
      @closed = false
      @prefill_email = submitted_email
      return render :new, status: :unprocessable_entity
    end

    attach_speaker!   # sets user + speaker BEFORE save (user is required)
    if @submission.save
      link_participation!
      send_confirmation!
      session.delete(:cfp_draft_id)
      redirect_to event_submit_path(@event),
        notice: @form.confirmation_message.presence || "Thanks! Your proposal “#{@submission.title}” was submitted."
    else
      @closed = false
      @prefill_email = submitted_email
      render :new, status: :unprocessable_entity
    end
  end

  # Save an in-progress proposal as a draft (as little as a title required).
  def draft
    build_submission("draft")
    @submission.abstract = @submission.abstract.presence || "(draft)"
    if @submission.title.blank?
      redirect_to(event_submit_path(@event), alert: "Enter a title to save a draft.") and return
    end
    if submitted_email.blank?
      redirect_to(event_submit_path(@event), alert: "Enter your email to save a draft.") and return
    end
    attach_speaker!
    if @submission.save
      link_participation!
      session[:cfp_draft_id] = @submission.id
      redirect_to event_submit_path(@event), notice: "Draft saved. You can finish it any time."
    else
      redirect_to event_submit_path(@event), alert: "Could not save draft."
    end
  end

  private

  def set_event = @event = Event.find_by!(slug: params[:event_id])
  def set_form  = @form = @event.cfp_form

  def load_draft
    id = session[:cfp_draft_id]
    id && @event.submissions.where(status: "draft", id: id).first
  end

  def reject_closed
    redirect_to event_submit_path(@event), alert: "The call for papers is closed."
  end

  def submitted_email
    (current_user&.email || params.dig(:submission, :contact_email).to_s).strip.downcase
  end

  def build_submission(status)
    @submission = load_draft || @event.submissions.build
    @submission.assign_attributes(submission_params)
    @submission.submission_form = @form
    @submission.answers = collect_answers
    @submission.status = status
  end

  def collect_answers
    raw = params[:answers]
    return {} if raw.blank?
    hash = raw.respond_to?(:to_unsafe_h) ? raw.to_unsafe_h : raw.to_h
    hash.transform_values { |v| v.is_a?(Array) ? v.reject(&:blank?) : v }
  end

  def missing_required
    missing = []
    missing << "Talk title" if @submission.title.blank?
    missing << "Abstract" if @submission.abstract.blank?
    @form.form_fields.select(&:required).each do |f|
      # Respect conditional visibility: only require it if its condition is met.
      next if f.conditional_value.present? && @submission.talk_format != f.conditional_value
      missing << f.label if @submission.answers[f.label].blank?
    end
    missing
  end

  # Resolve the submitter into a User + reusable profile + event speaker, and
  # assign them to the submission BEFORE it is saved (user is a required assoc).
  def attach_speaker!
    email = submitted_email
    name  = params.dig(:submission, :speaker_name).to_s.strip
    return if email.blank?

    user = current_user || User.find_or_create_by!(email: email) { |u| u.password = SecureRandom.hex(24); u.skip_name_validation = true }
    profile = user.speaker_profile || user.build_speaker_profile
    profile.name = name.presence || profile.name.presence || email
    profile.save!

    speaker = @event.event_speakers.find_or_initialize_by(email: email)
    speaker.name = name.presence || speaker.name.presence || email
    speaker.user = user
    speaker.status = speaker.status.presence || "invited"
    speaker.save!

    @submission.user = user
    @submission.speaker_profile = profile
    @submission.event_speaker = speaker
    @speaker = speaker
    @speaker_user = user
  end

  # After the submission is saved: co-speaker participant row + speaker membership.
  def link_participation!
    return unless @speaker
    @submission.session_participants.find_or_create_by!(event_speaker: @speaker) { |p| p.role = "Speaker" }
    @speaker_user.event_memberships.find_or_create_by!(event: @event, role: :speaker)
  end

  # Confirmation email to the submitter, recorded in the in-app comms log (CFP-08).
  def send_confirmation!
    email = submitted_email
    return if email.blank?
    subject = "We received your proposal for #{@event.name}"
    body = "Hi #{@speaker&.name || 'there'}, thanks for submitting “#{@submission.title}” to #{@event.name}. " \
           "You can track its status and manage your submission from your speaker portal: #{portal_root_url}"
    @event.communication_logs.create!(subject: subject, body: body, kind: "confirmation",
      recipients: [{ "name" => @speaker&.name, "email" => email }], sent_at: Time.current)
    EventMailer.generic(email, subject, body).deliver_later rescue nil
  end

  def submission_params
    params.require(:submission).permit(:title, :abstract, :talk_format, :track_id, :audience_level, :key_takeaway)
  end
end
