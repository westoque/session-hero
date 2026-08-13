module Portal
  class DeliverableCommentsController < BaseController
    before_action :set_session
    before_action :set_deliverable

    def create
      body = params.dig(:file_comment, :body).to_s
      if body.strip.blank?
        return redirect_to portal_session_path(@session), alert: "Comment can't be blank."
      end
      @deliverable.file_comments.create!(
        user: current_user,
        author_name: current_speakers.first&.name || current_user.display_name,
        body: body
      )
      redirect_to portal_session_path(@session), notice: "Comment posted."
    end

    private

    def set_session
      @session = my_sessions_scope.find_by(id: params[:session_id])
      redirect_to portal_sessions_path, alert: "That session isn't on your schedule." unless @session
    end

    def set_deliverable
      @deliverable = @session.deliverables.where(event_speaker_id: speaker_ids).find_by(id: params[:deliverable_id])
      redirect_to portal_session_path(@session), alert: "File not found." unless @deliverable
    end
  end
end
