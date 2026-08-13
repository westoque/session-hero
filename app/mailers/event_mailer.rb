class EventMailer < ApplicationMailer
  def generic(to, subject, body)
    @body = body
    mail(to: to, subject: subject) do |format|
      format.text { render plain: body.to_s }
    end
  end
end
