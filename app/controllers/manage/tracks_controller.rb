class Manage::TracksController < Manage::BaseController
  before_action :set_track, only: %i[edit update destroy]

  def index
    @tracks = @event.tracks.to_a
    @track = Track.new(event: @event, color: Track::PALETTE[@tracks.size % Track::PALETTE.size])
  end

  def create
    @event.tracks.create(track_params.merge(position: @event.tracks.count))
    redirect_to event_manage_tracks_path(@event), notice: "Track added."
  end

  def edit; end

  def update
    @track.update(track_params)
    redirect_to event_manage_tracks_path(@event), notice: "Track updated."
  end

  def destroy
    @track.destroy
    redirect_to event_manage_tracks_path(@event), notice: "Track removed."
  end

  private

  def set_track = @track = @event.tracks.find(params[:id])
  def track_params = params.require(:track).permit(:name, :color)
end
