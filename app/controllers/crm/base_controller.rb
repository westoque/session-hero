class Crm::BaseController < ApplicationController
  layout "crm"
  before_action :authenticate_user!

  private

  # Everything in the CRM is scoped to the signed-in organizer. This is an
  # org-level, cross-event address book — never nested under a single event.
  def contacts_scope = current_user.contacts
  helper_method :contacts_scope
end
