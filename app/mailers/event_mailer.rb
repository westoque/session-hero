class EventMailer < ApplicationMailer
  default from: "no-reply@sessionhero.example.com"

  def generic(to, subject, body)
    @body = body
    mail(to: to, subject: subject) do |format|
      format.text { render plain: body.to_s }
    end
  end
end
