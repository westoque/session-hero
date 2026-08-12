class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update]

  def index
    redirect_to dashboard_path
  end

  # Event home. Role-aware: renders a "Manage" door for organizers and a "Your
  # submissions" panel for speakers — both at once if you hold both roles here.
  def show
    @my_submissions = current_user.submissions.where(event: @event).order(created_at: :desc)
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    @event.creator = current_user
    if @event.save
      @event.event_memberships.create!(user: current_user, role: :organizer)
      redirect_to event_manage_root_path(@event),
                  notice: "Event created. Share your CFP link to collect submissions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to event_manage_root_path(@event), notice: "Event updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:id])
  end

  def event_params
    params.require(:event).permit(:name, :description, :starts_on, :ends_on,
                                  :cfp_opens_at, :cfp_closes_at, :status)
  end
end
