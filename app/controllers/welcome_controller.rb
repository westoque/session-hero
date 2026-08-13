class WelcomeController < ApplicationController
  # Signed-in users go straight to their dashboard; the root page is a public
  # marketing landing for logged-out visitors only.
  before_action :redirect_signed_in

  FEATURES = [
    ["📝", "Custom submission forms", "Build call-for-papers forms with conditional logic, custom fields, draft saving, and deadline enforcement."],
    ["⭐", "Committee review", "Multi-round scorecards, blind review, reviewer assignment, weighted scores, and CSV exports."],
    ["🎤", "Speaker portals", "Branded portals where speakers confirm, complete onboarding tasks, and upload slides and headshots."],
    ["🗓️", "Agenda builder", "Place accepted talks into rooms and time slots with automatic room and speaker conflict detection."],
    ["🌐", "Public widgets", "Publish an attendee-facing site — sessions, speakers, agenda, itinerary, and a speaker gallery — plus embeds."],
    ["📇", "Speaker CRM", "A cross-event contact database with a sourcing pipeline, segments, notes, and bulk outreach."],
  ].freeze

  def index
    @features = FEATURES
  end

  private

  def redirect_signed_in
    redirect_to dashboard_path if user_signed_in?
  end
end
