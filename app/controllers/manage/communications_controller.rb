class Manage::CommunicationsController < Manage::BaseController
  def index
    @logs = @event.communication_logs.limit(50)
  end

  def new
    @templates = @event.email_templates
    @speakers = @event.event_speakers
    @template = @templates.find_by(id: params[:template_id]) || @templates.first
    @recipients = @speakers
  end

  def create
    ids = Array(params[:speaker_ids]).reject(&:blank?)
    recipients = @event.event_speakers.where(id: ids)
    recipients = @event.event_speakers if recipients.empty? && params[:all].present?
    subject = params[:subject].to_s
    body = params[:body].to_s

    sent = recipients.map do |sp|
      ctx = { speaker_name: sp.name, first_name: sp.name.to_s.split.first, talk_title: sp.submissions.first&.title,
              event_name: @event.name, portal_link: portal_root_url }
      rendered_subject = EmailTemplate.render(subject, ctx)
      rendered_body = EmailTemplate.render(body, ctx)
      EventMailer.generic(sp.email, rendered_subject, rendered_body).deliver_later if sp.email.present? rescue nil
      { "name" => sp.name, "email" => sp.email }
    end

    @event.communication_logs.create!(user: current_user, subject: subject, body: body,
      recipients: sent, sent_at: Time.current)
    redirect_to event_manage_communications_path(@event), notice: "Sent to #{sent.size} recipient(s). Logged in history."
  end
end
