class PublicWidgetsController < ApplicationController
  # Public attendee-facing widgets — shareable, embeddable, no login required.
  layout "public"

  before_action :set_event, except: %i[featured embed feed]

  # ── 1. Sessions list (EMB-01,02,03) ─────────────────────────────
  def sessions
    load_sessions
  end

  # ── 2. Speakers directory (EMB-04,05) ───────────────────────────
  def speakers
    @speakers = sorted_speakers(@event.public_speakers)
    @total    = @event.public_speakers.size
    if (q = params[:q].to_s.strip.downcase).present?
      @speakers = @speakers.select { |s| s.name.to_s.downcase.include?(q) }
    end
  end

  # ── 3. Speaker detail (EMB-05,13) ───────────────────────────────
  def speaker
    @speaker  = @event.event_speakers.find(params[:speaker_id])
    @sessions = public_sessions_for(@speaker)
  end

  # ── 4. Per-day agenda grid (EMB-06,07,08) ───────────────────────
  def agenda
    load_agenda
    # EMB-08 detail panel
    @session = @event.public_sessions.detect { |s| s.id.to_s == params[:session].to_s } if params[:session].present?
  end

  # ── 5. Itinerary + personal schedule (EMB-09,10,11) ─────────────
  def itinerary
    @days = @event.agenda_days
    scheduled = @event.public_sessions.select(&:starts_at).sort_by(&:starts_at)
    @sessions_by_day = scheduled.group_by { |s| s.starts_at.to_date }
    @all_sessions    = scheduled
  end

  # ── 6. Speaker gallery grid (EMB-12,13) ─────────────────────────
  def gallery
    @speakers = sorted_speakers(@event.public_speakers)
    @total    = @event.public_speakers.size
    if (q = params[:q].to_s.strip.downcase).present?
      @speakers = @speakers.select { |s| s.name.to_s.downcase.include?(q) }
    end
  end

  # ── 7. Event site landing page (EMB-14) ─────────────────────────
  def site
    @session_count = @event.public_sessions.size
    @speaker_count = @event.public_speakers.size
  end

  # ── 8. Standalone embeddable widget (EMB-15) ────────────────────
  def embed
    @event  = Event.find_by!(slug: params[:event_id])
    @widget = params[:widget].to_s
    case @widget
    when "sessions" then load_sessions
    when "speakers", "gallery" then @speakers = sorted_speakers(@event.public_speakers)
    when "agenda"   then load_agenda
    else return redirect_to public_site_url_for(@event)
    end
    render "embed", layout: false
  end

  # ── 9. Data feed: JSON + iCal (EMB-11,15) ───────────────────────
  def feed
    @event = Event.find_by!(slug: params[:event_id])
    widget = params[:widget].to_s

    if params[:format].to_s == "ics"
      render plain: build_ics, content_type: "text/calendar"
    else
      render json: feed_json(widget)
    end
  end

  # ── 10. Top-level shortcuts → latest published event ────────────
  def featured
    event = Event.where(status: "published").order(updated_at: :desc).first
    return redirect_to root_path unless event

    widget = params[:widget].to_s
    path =
      case widget
      when "sessions"  then event_public_sessions_path(event)
      when "speakers"  then event_public_speakers_path(event)
      when "agenda"    then event_public_agenda_path(event)
      when "itinerary" then event_public_itinerary_path(event)
      when "gallery"   then event_public_gallery_path(event)
      else event_public_site_path(event)
      end
    redirect_to path
  end

  private

  def set_event
    @event = Event.find_by!(slug: params[:event_id])
  end

  # ── Sessions loading + faceted filtering ──────────────────────────
  def load_sessions
    all = @event.public_sessions.includes(:track, :room).to_a
    @total   = all.size
    @tracks  = all.map(&:track).compact.uniq.sort_by(&:name)
    @formats = all.map(&:talk_format).compact.uniq
    @rooms   = all.map(&:room).compact.uniq.sort_by(&:name)
    @sessions = apply_session_filters(all).sort_by { |s| [s.starts_at || Time.utc(0), s.title.to_s] }
  end

  def apply_session_filters(list)
    if (q = params[:q].to_s.strip.downcase).present?
      list = list.select do |s|
        s.title.to_s.downcase.include?(q) ||
          s.speakers.any? { |sp| sp.name.to_s.downcase.include?(q) }
      end
    end
    list = list.select { |s| s.track&.name == params[:track] } if params[:track].present?
    list = list.select { |s| s.talk_format == params[:format] } if params[:format].present?
    list = list.select { |s| s.room&.name == params[:room] } if params[:room].present?
    list
  end

  # ── Agenda grid loading ───────────────────────────────────────────
  def load_agenda
    @days = @event.agenda_days
    @day  = (@days.detect { |d| d.to_s == params[:day].to_s } || @days.first)
    @rooms = @event.rooms.to_a
    scheduled = @event.public_sessions.select(&:starts_at)
    @day_sessions = @day ? scheduled.select { |s| s.starts_at.to_date == @day }.sort_by(&:starts_at) : []
    starts = @day_sessions.map { |s| s.starts_at.hour }
    ends   = @day_sessions.map { |s| s.ends_at_or_default.hour + (s.ends_at_or_default.min.positive? ? 1 : 0) }
    @start_hour = ([starts.min, 9].compact.min) || 9
    @end_hour   = ([ends.max, 18].compact.max) || 18
  end

  # Sessions a speaker presents that are visible to the public.
  def public_sessions_for(speaker)
    public_ids = @event.public_sessions.map(&:id).to_set
    speaker.sessions.select { |s| public_ids.include?(s.id) }.sort_by { |s| s.starts_at || Time.utc(0) }
  end

  # Alphabetical by surname (last word of the name).
  def sorted_speakers(list)
    list.sort_by { |s| [s.name.to_s.split.last.to_s.downcase, s.name.to_s.downcase] }
  end

  def public_site_url_for(event)
    event_public_site_path(event)
  end

  # ── JSON feed payloads ────────────────────────────────────────────
  def feed_json(widget)
    case widget
    when "speakers", "gallery"
      @event.public_speakers.map { |s| { name: s.name, title: s.title, company: s.company } }
    else # sessions / agenda / itinerary
      @event.public_sessions.map do |s|
        {
          title: s.title,
          starts_at: s.starts_at&.iso8601,
          room: s.room&.name,
          track: s.track&.name,
          speakers: s.speakers.map(&:name)
        }
      end
    end
  end

  # ── iCal (VCALENDAR) builder ──────────────────────────────────────
  def build_ics
    sessions = @event.public_sessions.select(&:starts_at).sort_by(&:starts_at)
    lines = []
    lines << "BEGIN:VCALENDAR"
    lines << "VERSION:2.0"
    lines << "PRODID:-//SessionHero//#{ics_escape(@event.name)}//EN"
    lines << "CALSCALE:GREGORIAN"
    lines << "METHOD:PUBLISH"
    lines << "X-WR-CALNAME:#{ics_escape(@event.name)}"
    sessions.each do |s|
      lines << "BEGIN:VEVENT"
      lines << "UID:session-#{s.id}@#{@event.slug}"
      lines << "DTSTAMP:#{ics_time(Time.current)}"
      lines << "DTSTART:#{ics_time(s.starts_at)}"
      lines << "DTEND:#{ics_time(s.ends_at_or_default)}"
      lines << "SUMMARY:#{ics_escape(s.title)}"
      lines << "LOCATION:#{ics_escape(s.room&.name.to_s)}"
      desc = [s.track&.name, s.speaker_names].reject(&:blank?).join(" · ")
      lines << "DESCRIPTION:#{ics_escape(desc)}" if desc.present?
      lines << "END:VEVENT"
    end
    lines << "END:VCALENDAR"
    lines.join("\r\n") + "\r\n"
  end

  def ics_time(dt)
    dt.utc.strftime("%Y%m%dT%H%M%SZ")
  end

  def ics_escape(str)
    str.to_s.gsub("\\", "\\\\").gsub(/\r?\n/, "\\n").gsub(",", "\\,").gsub(";", "\\;")
  end
end
