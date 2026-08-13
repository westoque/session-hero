class Manage::EmbedsController < Manage::BaseController
  WIDGETS = %w[sessions speakers agenda gallery itinerary].freeze

  def index
    @widgets = WIDGETS
    @tracks = @event.tracks
  end
end
