class Crm::ContactNotesController < Crm::BaseController
  def create
    @contact = current_user.contacts.find(params[:contact_id])
    body = params.dig(:contact_note, :body).presence || params[:body]
    if body.present?
      @contact.contact_notes.create!(
        user: current_user, author_name: current_user.display_name,
        kind: "note", body: body
      )
      redirect_to crm_contact_path(@contact), notice: "Note added."
    else
      redirect_to crm_contact_path(@contact), alert: "Note can't be blank."
    end
  end
end
