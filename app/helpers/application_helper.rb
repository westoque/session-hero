module ApplicationHelper
  def title_tag
    content_for(:title).presence || Rails.application.class.module_parent_name.titleize
  end

  # Colored daisyUI badge for a submission's decision status.
  STATUS_BADGES = {
    "draft" => "badge-ghost", "submitted" => "badge-info", "under_review" => "badge-warning",
    "accepted" => "badge-success", "rejected" => "badge-error", "waitlisted" => "badge-secondary"
  }.freeze

  def status_badge(status)
    cls = STATUS_BADGES[status.to_s] || "badge-ghost"
    content_tag(:span, status.to_s.humanize, class: "badge #{cls} badge-sm")
  end

  CONTENT_BADGES = { "draft" => "badge-ghost", "in_review" => "badge-warning", "approved" => "badge-success" }.freeze
  def content_status_badge(status)
    cls = CONTENT_BADGES[status.to_s] || "badge-ghost"
    content_tag(:span, status.to_s.humanize, class: "badge #{cls} badge-sm")
  end

  def track_chip(track)
    return "" unless track
    content_tag(:span, track.name, class: "badge badge-sm border-0 text-white",
                style: "background-color: #{track.color}")
  end

  # Avatar: headshot thumbnail if attached, else initials placeholder.
  # Dimensions are inline styles (not Tailwind w-/h- classes) because the size is
  # dynamic — the JIT scanner never sees the literal class and would purge it.
  def speaker_avatar(speaker, size: 10)
    rem = (size * 0.25).round(3)
    dim = "width:#{rem}rem;height:#{rem}rem"
    if speaker.respond_to?(:headshot) && speaker.headshot.attached?
      image_tag(speaker.headshot, class: "rounded-full object-cover shrink-0", style: dim, alt: speaker.name)
    else
      fs = size <= 8 ? "text-xs" : (size <= 16 ? "text-sm" : "text-lg")
      seed = speaker.try(:email).presence || speaker.try(:name).to_s
      content_tag(:div, speaker.try(:initials).presence || "?",
                  style: "#{dim};background-color:#{avatar_color(seed)}",
                  class: "rounded-full text-white flex items-center justify-center font-semibold shrink-0 #{fs}")
    end
  end

  # Deterministic, pleasant avatar background per speaker so a gallery of
  # default (no-photo) avatars still looks varied and intentional.
  AVATAR_COLORS = %w[#2b8bff #9333ea #16a34a #db2777 #ea580c #0891b2 #4f46e5 #ca8a04].freeze
  def avatar_color(seed)
    AVATAR_COLORS[seed.to_s.bytes.sum % AVATAR_COLORS.size]
  end

  def fmt_datetime(dt)
    dt&.strftime("%b %-d, %Y · %-I:%M %p")
  end

  def fmt_date(d)
    d&.strftime("%b %-d, %Y")
  end
end
