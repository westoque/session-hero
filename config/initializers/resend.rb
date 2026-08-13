# API key for the Resend HTTP API, used by ActionMailer's :resend delivery
# method in production. Injected as a container ENV var via Kamal secrets.
Resend.api_key = ENV["RESEND_API_KEY"] if ENV["RESEND_API_KEY"].present?
