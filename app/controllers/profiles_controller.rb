class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile

  # The reusable speaker profile lives here — global to the user, NOT per event.
  def show; end

  def edit; end

  def update
    if @profile.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = current_user.speaker_profile ||
               current_user.build_speaker_profile(name: current_user.email)
  end

  def profile_params
    params.require(:speaker_profile).permit(:name, :headline, :bio, :company, :job_title)
  end
end
