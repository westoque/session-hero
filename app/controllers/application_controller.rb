class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  protected

  # One login, one dashboard per audience. The Devise scope is singular (:admin /
  # :user, from the models), so the default <scope>_root_path helpers don't line
  # up with our plural/flat routes — redirect explicitly.
  def after_sign_in_path_for(resource)
    case resource
    when Admin then admins_dashboard_path
    when User  then dashboard_path
    else super
    end
  end
end
