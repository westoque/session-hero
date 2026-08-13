module Portal
  class ProfileController < BaseController
    before_action :set_speaker

    def show
      redirect_to edit_portal_profile_path
    end

    def edit
    end

    def update
      # Persist text fields across every roster row for this user so the
      # organizer's record for this speaker is always in sync.
      current_speakers.each { |s| s.update!(profile_params) }

      if params.dig(:event_speaker, :headshot).present?
        current_speakers.each do |s|
          s.headshot.attach(params[:event_speaker][:headshot])
        end
      end

      redirect_to edit_portal_profile_path, notice: "Profile saved."
    rescue ActiveRecord::RecordInvalid => e
      @speaker = current_speakers.first
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end

    private

    def set_speaker
      @speaker = current_speakers.first
    end

    def profile_params
      params.require(:event_speaker)
            .permit(:name, :title, :company, :bio, :twitter, :linkedin, :travel_notes)
    end
  end
end
