class PublicSubmissionsController < ApplicationController
  # Public Call for Papers form — shareable link, no login required.
  before_action :set_event

  def new
    @submission = Submission.new
    @prefill_email = current_user&.email
  end

  def create
    email = (current_user&.email || params.dig(:submission, :contact_email).to_s).strip.downcase
    name  = params.dig(:submission, :speaker_name).to_s.strip
    @submission = @event.submissions.build(submission_params)

    if email.blank?
      @prefill_email = nil
      flash.now[:alert] = "Please provide your email so we can reach you."
      return render :new, status: :unprocessable_entity
    end

    # Find-or-create by email is what lets the SAME person be organizer here and
    # a speaker via this public form — one identity, a second (speaker) role.
    user = current_user || User.find_or_create_by!(email: email) do |u|
      u.password = SecureRandom.hex(24)
    end

    profile = user.speaker_profile || user.build_speaker_profile
    profile.name = name.presence || profile.name.presence || email
    profile.save!

    @submission.user = user
    @submission.speaker_profile = profile
    @submission.status = :submitted

    if @submission.save
      user.event_memberships.find_or_create_by!(event: @event, role: :speaker)
      redirect_to event_submit_path(@event),
                  notice: "Thanks! Your proposal “#{@submission.title}” was submitted."
    else
      @prefill_email = email
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  def submission_params
    params.require(:submission).permit(:title, :abstract, :talk_format)
  end
end
