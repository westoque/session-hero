class Manage::SettingsController < Manage::BaseController
  def show; end

  def update
    if @event.update(settings_params)
      redirect_to event_manage_settings_path(@event), notice: "Event settings saved."
    else
      flash.now[:alert] = "Could not save settings."
      render :show, status: :unprocessable_entity
    end
  end

  private

  def settings_params
    p = params.require(:event).permit(:name, :tagline, :description, :theme, :location,
      :timezone, :website_url, :event_type, :starts_on, :ends_on,
      :cfp_opens_at, :cfp_closes_at, :status, :logo, :background, :formats_text)
    if p[:formats_text]
      formats = p.delete(:formats_text).to_s.split("\n").map(&:strip).reject(&:blank?)
      @event.session_formats = formats if formats.any?
    end
    p
  end
end
