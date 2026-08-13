class Manage::AgendaController < Manage::BaseController
  HOURS = (8..18).to_a  # 8am–6pm slot grid

  def show
    @days = @event.agenda_days
    @day_index = (params[:day].presence || 0).to_i.clamp(0, [@days.size - 1, 0].max)
    @day = @days[@day_index]
    @rooms = @event.rooms
    @hours = HOURS
    @scheduled = @event.sessions.scheduled.includes(:room, :track, :participants)
    @unscheduled = @event.sessions.where(starts_at: nil).includes(:track, :participants)
    @conflicts = conflict_report
  end

  # Click-assign a session into a day/time/room slot (persists).
  def place
    sub = @event.submissions.find(params[:submission_id])
    if params[:unschedule].present?
      sub.update(starts_at: nil, ends_at: nil, room_id: nil)
      return redirect_to(agenda_path, notice: "Removed “#{sub.title}” from the schedule.")
    end
    day = @event.agenda_days[params[:day].to_i] || @event.starts_on
    hour = params[:hour].to_i
    mins = duration_minutes(sub)
    starts = Time.utc(day.year, day.month, day.day, hour, 0)
    sub.update(starts_at: starts, ends_at: starts + mins.minutes, room_id: params[:room_id].presence)
    sub.update(status: "accepted") unless sub.accepted?
    flash[:notice] = conflict_flash(sub) || "Placed “#{sub.title}”."
    redirect_to agenda_path(day: params[:day])
  end

  def publish
    @event.update(agenda_published: true)
    redirect_to agenda_path, notice: "Agenda published. It's live on the public site."
  end

  # Auto-place every unscheduled accepted session into the first free slot.
  def auto_schedule
    rooms = @event.rooms.to_a
    days = @event.agenda_days
    placed = 0
    @event.sessions.where(starts_at: nil).find_each do |sub|
      slot = first_free_slot(sub, days, rooms)
      next unless slot
      day, hour, room = slot
      starts = Time.utc(day.year, day.month, day.day, hour, 0)
      sub.update(starts_at: starts, ends_at: starts + duration_minutes(sub).minutes, room: room)
      placed += 1
    end
    redirect_to agenda_path, notice: "Auto-scheduler placed #{placed} unscheduled session(s)."
  end

  def conflicts
    @conflicts = conflict_report
    @days = @event.agenda_days
    render :conflicts
  end

  private

  def agenda_path(**opts) = event_manage_agenda_path(@event, **opts)

  def duration_minutes(sub)
    case sub.talk_format.to_s
    when /120/ then 120
    when /45/  then 45
    when /10/  then 10
    else 30
    end
  end

  def conflict_report
    @event.sessions.scheduled.flat_map do |s|
      s.room_conflicts.map { |o| { kind: "room", a: s, b: o } } +
        s.speaker_conflicts.map { |o| { kind: "speaker", a: s, b: o } }
    end.uniq { |c| [c[:kind], [c[:a].id, c[:b].id].sort] }
  end

  def conflict_flash(sub)
    parts = []
    parts << "⚠ Room conflict with #{sub.room_conflicts.map(&:title).to_sentence}" if sub.room_conflicts.any?
    if sub.speaker_conflicts.any?
      names = (sub.speakers.map(&:name) & sub.speaker_conflicts.flat_map { |c| c.speakers.map(&:name) }).uniq
      parts << "⚠ Speaker double-booked (#{names.to_sentence}) with #{sub.speaker_conflicts.map(&:title).to_sentence}"
    end
    parts.join(" · ").presence
  end

  def first_free_slot(sub, days, rooms)
    days.each do |day|
      HOURS.each do |hour|
        rooms.each do |room|
          starts = Time.utc(day.year, day.month, day.day, hour, 0)
          finish = starts + duration_minutes(sub).minutes
          clash = @event.sessions.scheduled.where(room: room).where.not(id: sub.id).any? do |o|
            starts < o.ends_at_or_default && o.starts_at < finish
          end
          speaker_clash = sub.speakers.any? do |sp|
            @event.sessions.scheduled.where.not(id: sub.id).any? do |o|
              o.speakers.include?(sp) && starts < o.ends_at_or_default && o.starts_at < finish
            end
          end
          return [day, hour, room] unless clash || speaker_clash
        end
      end
    end
    nil
  end
end
