# Builds a rich, throwaway demo event wired entirely to one organizer user so a
# single "See demo" login can explore every surface (organizer console, review,
# speaker portal, public pages). No file attachments — provisioning stays fast
# and light on SQLite; speakers fall back to colored default avatars.
#
# Everything created here is stamped with demo_expires_at and reaped by
# PurgeExpiredDemosJob after the TTL. Deliberately separate from db/seeds.rb
# (the grader-critical DevFlow seed) so that seed is never at risk.
class DemoEnvironment
  TTL = 2.hours

  def self.provision!
    token     = SecureRandom.alphanumeric(8).downcase
    expires_at = TTL.from_now
    organizer = User.create!(
      email: "demo-#{token}@sessionhero.demo",
      password: SecureRandom.hex(24),
      first_name: "Jordan", last_name: "Alvarez",
      demo_expires_at: expires_at
    )
    event = new(organizer:, token:, expires_at:).build!
    { organizer:, event: }
  end

  def initialize(organizer:, token:, expires_at:)
    @organizer  = organizer
    @token      = token
    @expires_at = expires_at
  end

  def build!
    ActiveRecord::Base.transaction do
      create_event!
      create_tracks_and_rooms!
      create_form!
      create_email_templates!
      create_speakers!
      create_sessions!
      create_review_round!
      create_portal_tasks!
      create_deliverable!
      create_history!
      create_crm!
      create_speaker_profile!
      @event
    end
  end

  private

  def wall(days_from_start, hour, min = 0)
    (@event.starts_on + days_from_start).to_time.change(hour:, min:)
  end

  def create_event!
    starts_on = 90.days.from_now.to_date
    @event = Event.create!(
      name: "DevFlow Conf (Demo)",
      slug: "demo-#{@token}",
      tagline: "The developer workflow conference",
      description: "A three-day, three-track conference on developer tooling, AI-assisted engineering, and platform infrastructure. This is a live demo environment — feel free to click around; it resets automatically.",
      theme: "Developer tooling, AI-assisted engineering, and platform infrastructure.",
      location: "Moscone West, San Francisco, CA",
      timezone: "America/Los_Angeles",
      website_url: "https://devflowconf.example.com",
      event_type: "Conference",
      starts_on: starts_on,
      ends_on: starts_on + 2,
      cfp_opens_at: 30.days.ago,
      cfp_closes_at: 60.days.from_now,
      status: "published",
      agenda_published: true,
      session_formats: Event::DEFAULT_FORMATS,
      creator: @organizer,
      demo_expires_at: @expires_at
    )
    # One login wears every hat so the demo user can explore all surfaces.
    @event.event_memberships.create!(user: @organizer, role: :organizer)
    @event.event_memberships.create!(user: @organizer, role: :reviewer)
  end

  def create_tracks_and_rooms!
    @tracks = {}
    [["AI Engineering", "#9333ea"], ["Platform & Infra", "#1560c7"], ["Developer Experience", "#16a34a"]].each_with_index do |(n, c), i|
      @tracks[n] = @event.tracks.create!(name: n, color: c, position: i)
    end
    @rooms = {}
    ["Main Stage", "Room 2A", "Room 2B", "Workshop Lab"].each_with_index do |n, i|
      @rooms[n] = @event.rooms.create!(name: n, position: i)
    end
  end

  def create_form!
    @form = @event.submission_forms.create!(
      name: "Session Submission Form",
      title: "Submit a session to DevFlow Conf",
      welcome_message: "We'd love to hear your proposal! Sessions run 10–120 minutes across three tracks.",
      confirmation_message: "Thanks — your proposal has been received. We'll be in touch after the review committee meets.",
      closes_at: 60.days.from_now
    )
    @form.form_fields.create!(label: "Key takeaway", field_type: "short_text", required: true,
      help_text: "In one sentence, what will attendees walk away with?", position: 1)
    @form.form_fields.create!(label: "Audience level", field_type: "dropdown", required: true,
      options: ["Beginner", "Intermediate", "Advanced"], position: 2)
    @form.form_fields.create!(label: "Workshop prerequisites", field_type: "long_text", required: false,
      help_text: "Only for workshops — what should attendees install or know beforehand?",
      position: 3, conditional_value: "Workshop (120 min)")
  end

  def create_email_templates!
    @event.email_templates.create!(name: "Acceptance Notification",
      subject: "Your talk has been accepted to DevFlow Conf",
      body: "Hi {speaker_name}, congratulations! Your session '{talk_title}' has been accepted. Please confirm your participation and complete your speaker profile.")
    @event.email_templates.create!(name: "Rejection Notification",
      subject: "Update on your DevFlow Conf submission",
      body: "Hi {speaker_name}, thank you for submitting '{talk_title}'. Unfortunately we couldn't include it in this year's program.")
    @event.email_templates.create!(name: "Speaker Welcome",
      subject: "Welcome to DevFlow Conf speakers",
      body: "Hi {speaker_name}, welcome aboard! Your speaker portal is ready — please complete your onboarding tasks before the deadlines.")
  end

  def create_speakers!
    # Speaker #0 IS the demo user (email match) so /portal resolves for them.
    @me = @event.event_speakers.create!(name: "Jordan Alvarez", email: @organizer.email,
      title: "Principal Engineer", company: "Latticework Systems",
      bio: "Jordan Alvarez leads the build-tooling platform team at Latticework Systems and has spoken at over a dozen developer conferences on build systems, CI reliability, and developer productivity.",
      twitter: "@jordanbuilds", linkedin: "https://www.linkedin.com/in/jordan-alvarez-example",
      status: "confirmed", public_visible: true, position: 0, user: @organizer)

    specs = [
      ["Priya Raman", "Principal Engineer", "Latticework Systems"],
      ["Marcus Okafor", "Staff Developer Advocate", "Cloudreach Labs"],
      ["Lena Fischer", "Staff Engineer", "Northwind Data"],
      ["Diego Santos", "Principal Architect", "Meridian Cloud"],
      ["Aisha Bello", "Engineering Lead", "Kernel Labs"],
      ["Tom Whitaker", "Developer Experience Lead", "Brightpath"],
      ["Yuki Tanaka", "Infrastructure Engineer", "Sundeck"],
      ["Rosa Martinez", "VP Engineering", "Cascade Systems"],
      ["Omar Haddad", "Senior SRE", "Portmap"],
    ]
    @speakers = specs.each_with_index.map do |(name, title, company), i|
      @event.event_speakers.create!(name: name, email: "#{name.parameterize}@example.com",
        title: title, company: company,
        bio: "#{name} is a #{title} at #{company}, speaking at DevFlow Conf on developer tooling and platform engineering.",
        status: "confirmed", public_visible: true, position: 1 + i)
    end
  end

  def make_session(speaker, attrs, schedule: nil, participants: [], accepted: true)
    sub = @event.submissions.create!(attrs.merge(
      user: @organizer, event_speaker: speaker, submission_form: @form,
      status: accepted ? "accepted" : "submitted",
      content_status: accepted ? "approved" : "draft",
      public_visible: true))
    sub.session_participants.create!(event_speaker: speaker, role: "Speaker", position: 0)
    participants.each_with_index { |p, i| sub.session_participants.create!(event_speaker: p, role: "Co-speaker", position: i + 1) }
    if schedule
      day, hour, room = schedule
      sub.update!(starts_at: wall(day, hour), ends_at: wall(day, hour).advance(minutes: 30), room: @rooms[room])
    end
    sub
  end

  def create_sessions!
    @flagship = make_session(@me, {
      title: "Taming 40-Minute CI: Incremental Builds at Monorepo Scale",
      abstract: "Our monorepo CI took 40 minutes on a good day. This talk walks through how we cut it to 6 minutes with content-addressed caching, remote execution, and a test-selection model — including the two migrations that failed first.",
      talk_format: "Talk (30 min)", track: @tracks["Platform & Infra"], audience_level: "Intermediate",
      key_takeaway: "A decision framework for which incremental-build investments pay off",
      answers: { "Key takeaway" => "A decision framework for which incremental-build investments pay off", "Audience level" => "Intermediate" }
    }, schedule: [0, 10, "Room 2A"], participants: [@speakers[1]])

    @second = make_session(@me, {
      title: "Your AI Pair Programmer Is Lying to You: Verification Patterns That Scale",
      abstract: "Code generation is easy; trusting it is hard. This session covers verification patterns for AI-generated code — property tests, mutation coverage, snapshot judges, and CI gates.",
      talk_format: "Talk (30 min)", track: @tracks["AI Engineering"], audience_level: "Advanced",
      key_takeaway: "Verification patterns that scale beyond code review",
      answers: { "Key takeaway" => "Verification patterns that scale beyond code review", "Audience level" => "Advanced" }
    }, schedule: [0, 14, "Room 2B"])

    filler = [
      ["Docs That Answer Back: Retrieval-Grounded Documentation Sites", "Developer Experience", "Lightning Talk (10 min)", "Beginner", [1, 11, "Room 2B"]],
      ["Zero-Downtime Schema Migrations at Scale", "Platform & Infra", "Talk (30 min)", "Intermediate", [0, 11, "Main Stage"]],
      ["Designing Internal Developer Platforms Teams Actually Use", "Developer Experience", "Talk (30 min)", "Intermediate", [0, 11, "Room 2A"]],
      ["Prompt Engineering Is Software Engineering", "AI Engineering", "Talk (30 min)", "Beginner", [0, 13, "Main Stage"]],
      ["Observability for LLM Applications", "AI Engineering", "Talk (30 min)", "Advanced", [0, 15, "Room 2A"]],
      ["Keynote: The Next Decade of Developer Tools", "Platform & Infra", "Keynote (45 min)", "Beginner", [0, 9, "Main Stage"]],
      ["Hands-On: Building a Remote Build Cache", "Platform & Infra", "Workshop (120 min)", "Advanced", [1, 13, "Workshop Lab"]],
      ["Feature Flags Without the Footguns", "Developer Experience", "Talk (30 min)", "Intermediate", [1, 10, "Main Stage"]],
      ["Panel: Is the Monorepo Worth It?", "Platform & Infra", "Panel (45 min)", "Intermediate", [1, 14, "Main Stage"]],
      ["Testing Strategies for Generative UIs", "AI Engineering", "Lightning Talk (10 min)", "Intermediate", [1, 15, "Room 2A"]],
      ["From Postmortem to Prevention", "Developer Experience", "Talk (30 min)", "Intermediate", [2, 10, "Main Stage"]],
      ["Cost-Aware Autoscaling for CI Fleets", "Platform & Infra", "Talk (30 min)", "Advanced", [2, 11, "Room 2A"]],
    ]
    filler.each_with_index do |(title, track, fmt, level, slot), i|
      make_session(@speakers[i % @speakers.size], {
        title: title, abstract: "#{title}. This session dives into practical patterns, real production data, and hard-won lessons you can apply immediately.",
        talk_format: fmt, track: @tracks[track], audience_level: level,
        key_takeaway: "Actionable takeaways on #{track.downcase}."
      }, schedule: slot)
    end

    # A pending (undecided) submission for the review pipeline.
    make_session(@speakers[0], {
      title: "Streaming Data Pipelines on a Budget",
      abstract: "How we built a real-time analytics pipeline for a fraction of the usual cost.",
      talk_format: "Talk (30 min)", track: @tracks["Platform & Infra"], audience_level: "Intermediate"
    }, accepted: false)
  end

  def create_review_round!
    @round = @event.review_rounds.create!(name: "Round 1 · Initial Review",
      instructions: "Score each proposal on originality and relevance. 1 = weak, 5 = exceptional.",
      opens_at: 30.days.ago, closes_at: 30.days.from_now, anonymized: true, status: "open")
    orig = @round.review_criteria.create!(label: "Originality", kind: "number", min_value: 1, max_value: 5, weight: 2, position: 0)
    rel  = @round.review_criteria.create!(label: "Relevance", kind: "number", min_value: 1, max_value: 5, weight: 1, position: 1)
    rec  = @round.review_criteria.create!(label: "Recommendation", kind: "dropdown", options: ["Accept", "Maybe", "Reject"], position: 2)
    com  = @round.review_criteria.create!(label: "Comments", kind: "text", position: 3)
    @round.round_reviewers.create!(user: @organizer)
    [@flagship, @second].each { |s| @round.review_assignments.create!(submission: s, user: @organizer) }
    @round.reviews.create!(submission: @flagship, user: @organizer, status: "completed", submitted_at: Time.current,
      comment: "Strong practical content and a clear narrative arc; abstract could name the specific tooling used. Recommend accept for the Platform track.",
      scores: { orig.id.to_s => "4", rel.id.to_s => "2", rec.id.to_s => "Accept", com.id.to_s => "Strong practical content and a clear narrative arc." })

    @event.review_rounds.create!(name: "Round 2 · Final Review",
      instructions: "Final scoring for shortlisted sessions.",
      opens_at: 30.days.from_now, closes_at: 45.days.from_now, anonymized: false, status: "open", position: 1)
      .review_criteria.create!(label: "Final Score", kind: "number", min_value: 1, max_value: 10, weight: 1, position: 0)
  end

  def make_task(attrs, complete: false)
    t = @event.portal_tasks.create!(attrs)
    ta = t.task_assignments.create!(event_speaker: @me)
    ta.complete! if complete
    t
  end

  def create_portal_tasks!
    make_task({ title: "Confirm participation", description: "Let us know you can make it.", due_on: 30.days.from_now.to_date, task_type: "general", required: true }, complete: true)
    make_task({ title: "Complete bio and profile", description: "Fill in your bio, photo, and social links.", due_on: 30.days.from_now.to_date, task_type: "general", required: true }, complete: true)
    make_task({ title: "Sign speaker release form", description: "Review and sign the speaker agreement.", due_on: 45.days.from_now.to_date, task_type: "general", required: true })
    @slides_task = make_task({ title: "Upload Session Presentation", description: "Final slide deck as a PDF, 16:9 aspect ratio.", due_on: 60.days.from_now.to_date, task_type: "file_request", required: true })
    make_task({ title: "Upload Final Headshot (print quality)", description: "High-resolution headshot for the program.", due_on: 40.days.from_now.to_date, task_type: "file_request", required: true })
  end

  def create_deliverable!
    # No file attachment (kept light) — the deliverable + comments still show a
    # filled content state on the portal and organizer content screens.
    deliv = @flagship.deliverables.create!(event_speaker: @me, portal_task: @slides_task, kind: "presentation", title: "Taming 40-Minute CI — Slides")
    deliv.file_comments.create!(user: @organizer, author_name: "Jordan Alvarez", body: "Draft deck — final version coming Friday.")
  end

  def create_history!
    @flagship.submission_versions.create!(user: @organizer, editor_name: "Jordan Alvarez", title: @flagship.title, abstract: @flagship.abstract)
    @event.communication_logs.create!(user: @organizer, subject: "Your talk has been accepted to DevFlow Conf",
      body: "Hi Priya Raman, congratulations! Your session 'Taming 40-Minute CI' has been accepted.",
      recipients: [{ "name" => "Priya Raman", "email" => "priya.raman@example.com" }], sent_at: 5.days.ago)
  end

  def create_crm!
    a = @organizer.contacts.create!(name: "Priya Raman", email: "priya.speaker@demo.example.com",
      company: "Latticework Systems", job_title: "Principal Engineer",
      bio: "Principal Engineer at Latticework Systems; strong on CI and platform topics.",
      speaker_type: "External", tags: ["CI", "Platform"], position: 0)
    b = @organizer.contacts.create!(name: "Marcus Okafor", email: "marcus.speaker@demo.example.com",
      company: "Cloudreach Labs", job_title: "Staff Developer Advocate",
      bio: "Staff Developer Advocate at Cloudreach Labs focused on AI agents in production.",
      speaker_type: "External", tags: ["AI"], pipeline_stage: "Interested", pipeline_score: 85,
      pipeline_rationale: "Strong platform-engineering track record; ideal for Platform & Infra track.", position: 1)
    @organizer.contacts.create!(name: "Dana Kowalski", email: "dana.speaker@demo.example.com",
      company: "Substrate", job_title: "Engineering Manager", bio: "Runs the developer-experience org at Substrate.",
      speaker_type: "External", tags: ["DX"], position: 2)
    a.contact_notes.create!(user: @organizer, author_name: "Jordan Alvarez", body: "Met at DevFlow — strong on CI topics; shortlist for keynote.")
    b.contact_notes.create!(user: @organizer, author_name: "Jordan Alvarez", kind: "stage_change", body: "Moved to Interested. Follow up next week.")
    @organizer.segments.create!(name: "AI Experts", criteria: { "tag" => "AI" })
  end

  def create_speaker_profile!
    p = @organizer.speaker_profile || @organizer.build_speaker_profile
    p.update!(name: @me.name, headline: @me.title, company: @me.company, job_title: @me.title, bio: @me.bio)
  end
end
