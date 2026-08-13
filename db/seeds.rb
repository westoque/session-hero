# DevFlow Conf 2027 — a fully populated demo event so every screen shows a
# realistic filled state and the eval's chained scenarios have real data to
# build on. Idempotent: re-running rebuilds the DevFlow event from scratch.

require "open-uri"

FIX = Rails.root.join("docs/killmysaas-evals/fixtures")
def attach_fixture(record, name, file, filename, content_type)
  path = FIX.join(file)
  return unless File.exist?(path)
  record.public_send(name).attach(io: File.open(path), filename: filename, content_type: content_type)
end

# Store intended wall-clock times directly (display is raw, no TZ conversion).
def wall(y, m, d, h, min = 0) = Time.utc(y, m, d, h, min)

puts "Seeding accounts…"
def upsert_user(email, password, first_name:, last_name:)
  u = User.find_or_initialize_by(email: email)
  u.password = password
  u.first_name = first_name
  u.last_name = last_name
  u.save!
  u
end

organizer = upsert_user("sbek-organizer@example.com", "SbekTest!2027-org",  first_name: "Olivia", last_name: "Bennett")
priya_u   = upsert_user("sbek-speaker@example.com",    "SbekTest!2027-spk",  first_name: "Priya",  last_name: "Raman")
marcus_u  = upsert_user("sbek-speaker2@example.com",   "SbekTest!2027-spk2", first_name: "Marcus", last_name: "Okafor")
sam_u     = upsert_user("sbek-reviewer@example.com",   "SbekTest!2027-rev",  first_name: "Sam",    last_name: "Rivera")
alex_u    = upsert_user("sbek-attendee@example.com",   "SbekTest!2027-att",  first_name: "Alex",   last_name: "Kim")

puts "Rebuilding DevFlow Conf 2027…"
Event.where(slug: "devflow-conf-2027").destroy_all
event = Event.create!(
  name: "DevFlow Conf 2027",
  slug: "devflow-conf-2027",
  tagline: "The developer workflow conference",
  description: "A three-day, three-track conference on developer tooling, AI-assisted engineering, and platform infrastructure.",
  theme: "Developer tooling, AI-assisted engineering, and platform infrastructure.",
  location: "Moscone West, San Francisco, CA",
  timezone: "America/Los_Angeles",
  website_url: "https://devflowconf.example.com",
  event_type: "Conference",
  starts_on: Date.new(2027, 5, 12),
  ends_on: Date.new(2027, 5, 14),
  cfp_opens_at: wall(2026, 8, 1, 9),
  cfp_closes_at: wall(2027, 4, 30, 23, 59),
  status: "published",
  agenda_published: true,
  session_formats: Event::DEFAULT_FORMATS,
  creator: organizer
)
event.event_memberships.create!(user: organizer, role: :organizer)
event.event_memberships.create!(user: sam_u, role: :reviewer)
attach_fixture(event, :logo, "headshot.png", "devflow-logo.png", "image/png")

# ── Tracks & rooms ──────────────────────────────────────────────────
tracks = {}
[["AI Engineering", "#9333ea"], ["Platform & Infra", "#1560c7"], ["Developer Experience", "#16a34a"]].each_with_index do |(n, c), i|
  tracks[n] = event.tracks.create!(name: n, color: c, position: i)
end
rooms = {}
["Main Stage", "Room 2A", "Room 2B", "Workshop Lab"].each_with_index do |n, i|
  rooms[n] = event.rooms.create!(name: n, position: i)
end

# ── Submission form with custom + conditional fields ────────────────
form = event.submission_forms.create!(
  name: "Session Submission Form",
  title: "Submit a session to DevFlow Conf 2027",
  welcome_message: "We'd love to hear your proposal! Sessions run 10–120 minutes across three tracks. The call closes April 30, 2027.",
  confirmation_message: "Thanks — your proposal has been received. We'll be in touch after the review committee meets.",
  closes_at: wall(2027, 4, 30, 23, 59)
)
f_takeaway = form.form_fields.create!(label: "Key takeaway", field_type: "short_text", required: true,
  help_text: "In one sentence, what will attendees walk away with?", position: 1)
f_level = form.form_fields.create!(label: "Audience level", field_type: "dropdown", required: true,
  options: ["Beginner", "Intermediate", "Advanced"], position: 2)
form.form_fields.create!(label: "Workshop prerequisites", field_type: "long_text", required: false,
  help_text: "Only for workshops — what should attendees install or know beforehand?",
  position: 3, conditional_field_id: nil, conditional_value: "Workshop (120 min)")
# The conditional trigger is the format question (built into the form UI); we
# store the trigger value so the public form can show/hide it.

# ── Email templates ─────────────────────────────────────────────────
event.email_templates.create!(name: "Acceptance Notification",
  subject: "Your talk has been accepted to DevFlow Conf 2027",
  body: "Hi {speaker_name}, congratulations! Your session '{talk_title}' has been accepted. Please confirm your participation and complete your speaker profile by April 1, 2027.")
event.email_templates.create!(name: "Rejection Notification",
  subject: "Update on your DevFlow Conf 2027 submission",
  body: "Hi {speaker_name}, thank you for submitting '{talk_title}'. Unfortunately we couldn't include it in this year's program. We hope you'll submit again next year.")
event.email_templates.create!(name: "Speaker Welcome",
  subject: "Welcome to DevFlow Conf 2027 speakers",
  body: "Hi {speaker_name}, welcome aboard! Your speaker portal is ready — please complete your onboarding tasks before the deadlines.")

# ── Speakers (roster / event_speakers) ──────────────────────────────
def make_speaker(event, attrs, headshot: true, user: nil)
  s = event.event_speakers.create!(attrs.merge(user: user))
  attach_fixture(s, :headshot, "headshot.png", "#{s.name.parameterize}.png", "image/png") if headshot
  s
end

priya = make_speaker(event, { name: "Priya Raman", email: "sbek-speaker@example.com",
  title: "Principal Engineer", company: "Latticework Systems",
  bio: "Priya Raman is a Principal Engineer at Latticework Systems where she leads the build-tooling platform team. She previously maintained the open-source task runner 'gantry' and has spoken at over a dozen developer conferences on build systems, CI reliability, and developer productivity metrics.",
  twitter: "@priyabuilds", linkedin: "https://www.linkedin.com/in/priya-raman-example",
  status: "confirmed", public_visible: true, position: 0 }, user: priya_u)

marcus = make_speaker(event, { name: "Marcus Okafor", email: "sbek-speaker2@example.com",
  title: "Staff Developer Advocate", company: "Cloudreach Labs",
  bio: "Marcus Okafor is a Staff Developer Advocate at Cloudreach Labs focused on AI agents in production. He writes the newsletter 'Agents Weekly' and co-organizes the SF AI Tinkerers meetup.",
  status: "confirmed", public_visible: true, position: 1 }, user: marcus_u)

# Extra speakers to fill the roster / gallery / agenda.
extra_specs = [
  ["Lena Fischer", "Staff Engineer", "Northwind Data", true],
  ["Diego Santos", "Principal Architect", "Meridian Cloud", true],
  ["Aisha Bello", "Engineering Lead", "Kernel Labs", true],
  ["Tom Whitaker", "Developer Experience Lead", "Brightpath", false], # no headshot → gallery fallback
  ["Yuki Tanaka", "Infrastructure Engineer", "Sundeck", true],
  ["Rosa Martinez", "VP Engineering", "Cascade Systems", true],
  ["Omar Haddad", "Senior SRE", "Portmap", true],
  ["Grace Lee", "Product Engineer", "Fernweh", true],
]
extras = extra_specs.each_with_index.map do |(name, title, company, hs), i|
  make_speaker(event, { name: name, email: "#{name.parameterize}@example.com",
    title: title, company: company,
    bio: "#{name} is a #{title} at #{company}, speaking at DevFlow Conf 2027 on developer tooling and platform engineering.",
    status: "confirmed", public_visible: true, position: 2 + i }, headshot: hs)
end

# ── Sessions (submissions) ──────────────────────────────────────────
def make_session(event, form, speaker, user, attrs, schedule: nil, participants: [], accepted: true)
  sub = event.submissions.create!(attrs.merge(
    user: user, event_speaker: speaker, submission_form: form,
    status: accepted ? "accepted" : "submitted",
    content_status: accepted ? "approved" : "draft",
    public_visible: true))
  sub.session_participants.create!(event_speaker: speaker, role: "Speaker", position: 0)
  participants.each_with_index { |p, i| sub.session_participants.create!(event_speaker: p, role: "Co-speaker", position: i + 1) }
  if schedule
    day, hour, room = schedule
    sub.update!(starts_at: wall(2027, 5, day, hour), ends_at: wall(2027, 5, day, hour, 30), room: rooms_for(event)[room])
  end
  sub
end

def rooms_for(event) = @rooms_cache ||= event.rooms.index_by(&:name)

# The three fixture proposals (exact titles the eval reuses).
taming = make_session(event, form, priya, priya_u, {
  title: "Taming 40-Minute CI: Incremental Builds at Monorepo Scale",
  abstract: "Our monorepo CI took 40 minutes on a good day. This talk walks through how we cut it to 6 minutes with content-addressed caching, remote execution, and a test-selection model — including the two migrations that failed first. You'll leave with a decision framework for which incremental-build investments pay off at which repo sizes, and the graphs to convince your platform team.",
  talk_format: "Talk (30 min)", track: tracks["Platform & Infra"], audience_level: "Intermediate",
  key_takeaway: "A decision framework for which incremental-build investments pay off",
  answers: { "Key takeaway" => "A decision framework for which incremental-build investments pay off", "Audience level" => "Intermediate" }
}, schedule: [12, 10, "Room 2A"], participants: [marcus])

ai_pair = make_session(event, form, priya, priya_u, {
  title: "Your AI Pair Programmer Is Lying to You: Verification Patterns That Scale",
  abstract: "Code generation is easy; trusting it is hard. This session covers verification patterns for AI-generated code — property tests, mutation coverage, snapshot judges, and CI gates — with data from 18 months of running them on a 200-engineer codebase. Includes what we stopped doing because it didn't catch anything.",
  talk_format: "Talk (30 min)", track: tracks["AI Engineering"], audience_level: "Advanced",
  key_takeaway: "Verification patterns that scale beyond code review",
  answers: { "Key takeaway" => "Verification patterns that scale beyond code review", "Audience level" => "Advanced" }
}, schedule: [12, 14, "Room 2B"])

docs = make_session(event, form, marcus, marcus_u, {
  title: "Docs That Answer Back: Retrieval-Grounded Documentation Sites",
  abstract: "A 10-minute tour of turning a static docs site into one that answers questions with citations, stays honest when it doesn't know, and costs under $50/month to run. Live demo, real failure cases, and a checklist you can apply to your own docs this week.",
  talk_format: "Lightning Talk (10 min)", track: tracks["Developer Experience"], audience_level: "Beginner",
  key_takeaway: "Turn static docs into a grounded Q&A site for under $50/month",
  answers: { "Key takeaway" => "Turn static docs into a grounded Q&A site for under $50/month", "Audience level" => "Beginner" }
}, schedule: [13, 11, "Room 2B"])

agents_q = make_session(event, form, marcus, marcus_u, {
  title: "Lightning: Agents in Production Q&A",
  abstract: "Rapid-fire lessons from shipping autonomous agents to real users: guardrails, cost control, evals, and the failure modes nobody warns you about.",
  talk_format: "Lightning Talk (10 min)", track: tracks["AI Engineering"], audience_level: "Intermediate",
  key_takeaway: "Practical guardrails for agents in production"
}) # left UNSCHEDULED for the auto-schedule scenario

# Filler sessions to populate the agenda/widgets.
titles = [
  ["Zero-Downtime Schema Migrations at Scale", "Platform & Infra", "Talk (30 min)", "Intermediate"],
  ["Designing Internal Developer Platforms Teams Actually Use", "Developer Experience", "Talk (30 min)", "Intermediate"],
  ["Prompt Engineering Is Software Engineering", "AI Engineering", "Talk (30 min)", "Beginner"],
  ["Observability for LLM Applications", "AI Engineering", "Talk (30 min)", "Advanced"],
  ["Keynote: The Next Decade of Developer Tools", "Platform & Infra", "Keynote (45 min)", "Beginner"],
  ["Hands-On: Building a Remote Build Cache", "Platform & Infra", "Workshop (120 min)", "Advanced"],
  ["Feature Flags Without the Footguns", "Developer Experience", "Talk (30 min)", "Intermediate"],
  ["Panel: Is the Monorepo Worth It?", "Platform & Infra", "Panel (45 min)", "Intermediate"],
  ["Testing Strategies for Generative UIs", "AI Engineering", "Lightning Talk (10 min)", "Intermediate"],
  ["From Postmortem to Prevention", "Developer Experience", "Talk (30 min)", "Intermediate"],
  ["Cost-Aware Autoscaling for CI Fleets", "Platform & Infra", "Talk (30 min)", "Advanced"],
  ["Docs-as-Tests: Keeping Examples Honest", "Developer Experience", "Lightning Talk (10 min)", "Beginner"],
]
schedule_slots = [
  [12, 11, "Main Stage"], [12, 11, "Room 2A"], [12, 13, "Main Stage"], [12, 15, "Room 2A"],
  [12, 9, "Main Stage"], [13, 13, "Workshop Lab"], [13, 10, "Main Stage"], [13, 14, "Main Stage"],
  [13, 15, "Room 2A"], [14, 10, "Main Stage"], [14, 11, "Room 2A"], [14, 13, "Main Stage"],
]
titles.each_with_index do |(title, track, fmt, level), i|
  sp = extras[i % extras.size]
  make_session(event, form, sp, organizer, {
    title: title, abstract: "#{title}. This session dives into practical patterns, real production data, and hard-won lessons you can apply immediately.",
    talk_format: fmt, track: tracks[track], audience_level: level,
    key_takeaway: "Actionable takeaways on #{track.downcase}."
  }, schedule: schedule_slots[i])
end

# A couple of pending (not yet decided) submissions for the review pipeline.
pending1 = make_session(event, form, extras[0], organizer, {
  title: "Streaming Data Pipelines on a Budget", abstract: "How we built a real-time analytics pipeline for a fraction of the usual cost.",
  talk_format: "Talk (30 min)", track: tracks["Platform & Infra"], audience_level: "Intermediate"
}, accepted: false)

puts "  #{event.submissions.count} sessions, #{event.event_speakers.count} speakers"

# ── Review round 1 with scorecard, reviewer pool, assignments ───────
round1 = event.review_rounds.create!(name: "Round 1 · Initial Review",
  instructions: "Score each proposal on originality and relevance. 1 = weak, 5 = exceptional.",
  opens_at: wall(2026, 8, 1, 9), closes_at: wall(2026, 10, 15, 23, 59), anonymized: true, status: "open")
c_orig = round1.review_criteria.create!(label: "Originality", kind: "number", min_value: 1, max_value: 5, weight: 2, position: 0)
c_rel  = round1.review_criteria.create!(label: "Relevance", kind: "number", min_value: 1, max_value: 5, weight: 1, position: 1)
round1.review_criteria.create!(label: "Recommendation", kind: "dropdown", options: ["Accept", "Maybe", "Reject"], position: 2)
round1.review_criteria.create!(label: "Comments", kind: "text", position: 3)
round1.round_reviewers.create!(user: sam_u)
[taming, ai_pair].each { |s| round1.review_assignments.create!(submission: s, user: sam_u) }

round2 = event.review_rounds.create!(name: "Round 2 · Final Review",
  instructions: "Final scoring for shortlisted sessions.",
  opens_at: wall(2026, 10, 16, 9), closes_at: wall(2026, 11, 30, 23, 59), anonymized: false, status: "open", position: 1)
round2.review_criteria.create!(label: "Final Score", kind: "number", min_value: 1, max_value: 10, weight: 1, position: 0)
round2.review_criteria.create!(label: "Comments", kind: "text", position: 1)

# One completed review already on the books (so results screens are filled).
crit = round1.review_criteria.where(kind: %w[number dropdown text]).index_by(&:label)
round1.reviews.create!(submission: taming, user: sam_u, status: "completed", submitted_at: Time.current,
  comment: "Strong practical content and a clear narrative arc; abstract could name the specific tooling used. Recommend accept for the Platform track.",
  scores: { crit["Originality"].id.to_s => "4", crit["Relevance"].id.to_s => "2",
            crit["Recommendation"].id.to_s => "Accept", crit["Comments"].id.to_s => "Strong practical content and a clear narrative arc." })

# ── Portal onboarding tasks ─────────────────────────────────────────
def make_task(event, attrs, speakers, complete_for: [])
  t = event.portal_tasks.create!(attrs)
  speakers.each do |s|
    ta = t.task_assignments.create!(event_speaker: s)
    ta.complete! if complete_for.include?(s)
  end
  t
end

t_confirm = make_task(event, { title: "Confirm participation", description: "Let us know you can make it.", due_on: Date.new(2027, 4, 1), task_type: "general", required: true }, [priya, marcus], complete_for: [priya])
t_bio     = make_task(event, { title: "Complete bio and profile", description: "Fill in your bio, photo, and social links.", due_on: Date.new(2027, 4, 1), task_type: "general", required: true }, [priya, marcus], complete_for: [priya])
t_release = make_task(event, { title: "Sign speaker release form", description: "Review and sign the speaker agreement.", due_on: Date.new(2027, 4, 15), task_type: "general", required: true }, [priya, marcus])
t_slides  = make_task(event, { title: "Upload Session Presentation", description: "Final slide deck as a PDF, 16:9 aspect ratio.", due_on: Date.new(2027, 5, 1), task_type: "file_request", required: true }, [priya, marcus])
t_head    = make_task(event, { title: "Upload Final Headshot (print quality)", description: "High-resolution headshot for the program.", due_on: Date.new(2027, 4, 14), task_type: "file_request", required: true }, [priya, marcus])

# ── A deliverable with two versions + a comment (filled content state) ─
deliv = taming.deliverables.create!(event_speaker: priya, portal_task: t_slides, kind: "presentation", title: "Taming 40-Minute CI — Slides")
2.times do |i|
  v = deliv.file_versions.create!(version_number: i + 1, created_at: (2 - i).days.ago)
  path = FIX.join("slides.pdf")
  v.file.attach(io: File.open(path), filename: "taming-ci-slides.pdf", content_type: "application/pdf") if File.exist?(path)
end
deliv.file_comments.create!(user: priya_u, author_name: "Priya Raman", body: "Draft deck - final version coming Friday.", created_at: 2.days.ago)
deliv.file_comments.create!(user: organizer, author_name: "Jordan Alvarez (Organizer)", body: "Thanks — please use the event slide template for the title card.", created_at: 1.day.ago)
TaskAssignment.where(portal_task: t_slides, event_speaker: priya).first&.complete!

# ── Change history on the flagship session ──────────────────────────
taming.submission_versions.create!(user: organizer, editor_name: "Jordan Alvarez", title: taming.title, abstract: taming.abstract, created_at: 3.days.ago)

# ── Communication history ───────────────────────────────────────────
event.communication_logs.create!(user: organizer, subject: "Your talk has been accepted to DevFlow Conf 2027",
  body: "Hi Priya Raman, congratulations! Your session 'Taming 40-Minute CI' has been accepted.",
  recipients: [{ "name" => "Priya Raman", "email" => "sbek-speaker@example.com" }], sent_at: 5.days.ago)

# ── Speaker profiles for logins (so /profile is prefilled) ──────────
[[priya_u, priya], [marcus_u, marcus]].each do |u, sp|
  p = u.speaker_profile || u.build_speaker_profile
  p.update!(name: sp.name, headline: sp.title, company: sp.company, job_title: sp.title, bio: sp.bio)
end

# ── Speaker CRM (org-level directory for the organizer) ─────────────
puts "Seeding CRM directory…"
organizer.contacts.destroy_all
crm_priya = organizer.contacts.create!(name: "Priya Raman", email: "priya.speaker@sbek-test.example.com",
  company: "Latticework Systems", job_title: "Principal Engineer", bio: priya.bio,
  speaker_type: "External", tags: ["CI", "Platform"], position: 0)
crm_marcus = organizer.contacts.create!(name: "Marcus Okafor", email: "marcus.speaker@sbek-test.example.com",
  company: "Cloudreach Labs", job_title: "Staff Developer Advocate", bio: marcus.bio,
  speaker_type: "External", tags: ["AI"], pipeline_stage: "Interested", pipeline_score: 85,
  pipeline_rationale: "Strong platform-engineering track record; ideal for Platform & Infra track.", position: 1)
organizer.contacts.create!(name: "Dana Kowalski", email: "dana.speaker@sbek-test.example.com",
  company: "Substrate", job_title: "Engineering Manager", bio: "Runs the developer-experience org at Substrate.",
  speaker_type: "External", tags: ["DX"], position: 2)
crm_priya.contact_notes.create!(user: organizer, author_name: "Jordan Alvarez",
  body: "Met at DevFlow 2026 - strong on CI topics; shortlist for keynote.")
crm_marcus.contact_notes.create!(user: organizer, author_name: "Jordan Alvarez", kind: "stage_change",
  body: "Moved to Interested. Left voicemail 2027-01-15; follow up next week.", created_at: 3.days.ago)
organizer.segments.create!(name: "AI Experts", criteria: { "tag" => "AI" })

puts "Done. DevFlow Conf 2027 → /events/#{event.slug}"
puts "  organizer: sbek-organizer@example.com / SbekTest!2027-org"
puts "  speaker:   sbek-speaker@example.com / SbekTest!2027-spk"
puts "  reviewer:  sbek-reviewer@example.com / SbekTest!2027-rev"
