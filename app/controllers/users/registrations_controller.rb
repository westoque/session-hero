class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # Devise requires the current password for every account update by default.
  # We only want that when the user is actually changing their email or
  # password — plain profile edits (first/last name) save without it.
  def update_resource(resource, params)
    changing_credentials =
      params[:password].present? ||
      params[:password_confirmation].present? ||
      (params[:email].present? && params[:email].to_s.downcase != resource.email.to_s.downcase)

    if changing_credentials
      super
    else
      resource.update_without_password(params.except(:current_password, :password, :password_confirmation))
    end
  end
end
