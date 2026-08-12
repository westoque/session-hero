class HealthcheckSilencer
  def initialize(app)
    @app = app
  end

  def call(env)
    return @app.call(env) unless env["PATH_INFO"] == "/up"

    Rails.logger.silence { @app.call(env) }
  end
end
