class Manage::RoomsController < Manage::BaseController
  before_action :set_room, only: %i[edit update destroy]

  def index
    @rooms = @event.rooms.to_a
    @room = Room.new(event: @event)
  end

  def create
    @event.rooms.create(room_params.merge(position: @event.rooms.count))
    redirect_to event_manage_rooms_path(@event), notice: "Room added."
  end

  def edit; end

  def update
    @room.update(room_params)
    redirect_to event_manage_rooms_path(@event), notice: "Room updated."
  end

  def destroy
    @room.destroy
    redirect_to event_manage_rooms_path(@event), notice: "Room removed."
  end

  private

  def set_room = @room = @event.rooms.find(params[:id])
  def room_params = params.require(:room).permit(:name)
end
