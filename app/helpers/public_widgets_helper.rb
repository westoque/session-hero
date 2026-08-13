module PublicWidgetsHelper
  # Truncated text with an inline "Show more" toggle that expands the full copy
  # in place — no navigation, no extra Stimulus controller. CSP allows inline JS.
  def disclosure_text(text, length: 180, css: "text-sm opacity-80")
    text = text.to_s.strip
    return "".html_safe if text.blank?

    if text.length <= length
      return content_tag(:p, text, class: css)
    end

    js = "var w=this.closest('[data-disclosure]');" \
         "w.querySelectorAll('.dc-short,.dc-full').forEach(function(e){e.classList.toggle('hidden')});" \
         "this.textContent=(this.textContent.trim()==='Show more')?'Show less':'Show more';"

    content_tag(:div, class: css, data: { disclosure: true }) do
      concat content_tag(:span, truncate(text, length: length, separator: " "), class: "dc-short")
      concat content_tag(:span, text, class: "dc-full hidden")
      concat content_tag(:button, "Show more", type: "button",
                         class: "link link-primary text-xs ml-1 whitespace-nowrap", onclick: js)
    end
  end

  # A speaker's job line: "Title, Company" with graceful blanks.
  def speaker_role(speaker)
    [speaker.title, speaker.company].reject(&:blank?).join(", ")
  end
end
