class Admins::BaseController < ApplicationController
  before_action :authenticate_admin!

  layout "admins"
end
