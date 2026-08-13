class WelcomeController < ApplicationController
  def index
    @events = Event.where(status: "published").order(starts_on: :asc)
    @events = Event.all.order(created_at: :desc) if @events.empty?
    @featured = @events.first
  end
end
