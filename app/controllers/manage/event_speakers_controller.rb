require "csv"

class Manage::EventSpeakersController < Manage::BaseController
  before_action :set_speaker, only: %i[show edit update destroy]

  def index
    @speakers = @event.event_speakers
    @speakers = @speakers.where("name LIKE :q OR email LIKE :q OR company LIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    @speakers = @speakers.where(status: params[:status]) if params[:status].present?
  end

  def show
    @sessions = @speaker.submissions
    @assignments = @speaker.task_assignments.includes(:portal_task)
  end

  def new = @speaker = @event.event_speakers.new(status: "invited")
  def edit; end

  def create
    @speaker = @event.event_speakers.new(speaker_params)
    if @speaker.save
      redirect_to event_manage_speaker_path(@event, @speaker), notice: "Speaker added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @speaker.update(speaker_params)
      redirect_to event_manage_speaker_path(@event, @speaker), notice: "Speaker updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @speaker.destroy
    redirect_to event_manage_speakers_path(@event), notice: "Speaker removed."
  end

  # CSV bulk import (columns: name,email,title,company,bio)
  def import
    return if request.get?
    file = params[:file]
    return redirect_to(event_manage_speakers_path(@event), alert: "Choose a CSV file.") unless file
    created = 0; updated = 0
    CSV.parse(file.read, headers: true) do |row|
      h = row.to_h.transform_keys { |k| k.to_s.strip.downcase }
      next if h["name"].blank?
      sp = @event.event_speakers.find_or_initialize_by(email: h["email"].to_s.strip.presence || "#{h['name'].parameterize}@example.com")
      sp.new_record? ? created += 1 : updated += 1
      sp.assign_attributes(name: h["name"], title: h["title"], company: h["company"], bio: h["bio"], status: sp.status || "invited")
      sp.save
    end
    redirect_to event_manage_speakers_path(@event), notice: "Imported #{created} new speaker(s), updated #{updated}."
  end

  def bulk_status
    ids = Array(params[:speaker_ids]).reject(&:blank?)
    @event.event_speakers.where(id: ids).update_all(status: params[:status]) if params[:status].present?
    redirect_to event_manage_speakers_path(@event), notice: "Updated #{ids.size} speaker(s)."
  end

  private

  def set_speaker = @speaker = @event.event_speakers.find(params[:id])

  def speaker_params
    params.require(:event_speaker).permit(:name, :email, :title, :company, :bio,
      :twitter, :linkedin, :status, :travel_notes, :public_visible, :headshot)
  end
end
