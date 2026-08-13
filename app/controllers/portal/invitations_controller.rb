module Portal
  class InvitationsController < BaseController
    def update
      # params[:id] is one of the current user's own EventSpeaker roster rows.
      speaker = current_speakers.detect { |s| s.id.to_s == params[:id].to_s }
      unless speaker
        return redirect_to portal_root_path, alert: "Invitation not found."
      end
      speaker.update!(status: "confirmed")
      redirect_back fallback_location: portal_root_path, notice: "Invitation accepted. Welcome aboard!"
    end
  end
end
