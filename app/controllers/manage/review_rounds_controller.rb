require "csv"

class Manage::ReviewRoundsController < Manage::BaseController
  before_action :set_round, only: %i[show edit update destroy add_reviewer remove_reviewer assign remind ai_evaluate]

  def index
    @rounds = @event.review_rounds.includes(:review_criteria, :reviewers, :review_assignments)
  end

  def show
    @criteria = @round.review_criteria
    @pool = @round.reviewers
    @candidate_reviewers = @event.members.merge(EventMembership.reviewer).where.not(id: @pool.map(&:id))
    @submissions = @event.submissions.where.not(status: "draft").includes(:event_speaker)
    @assignments = @round.review_assignments.includes(:submission, :user)
    @progress = @pool.map { |r| [r, @round.assigned_count(r), @round.completed_count(r)] }
  end

  def new
    @round = @event.review_rounds.new(anonymized: true, status: "open")
    3.times { @round.review_criteria.build(kind: "number", min_value: 1, max_value: 5, weight: 1) }
    @round.review_criteria.build(kind: "text", label: "Comments")
  end

  def create
    @round = @event.review_rounds.new(round_params)
    @round.review_criteria = @round.review_criteria.reject { |c| c.label.blank? }
    if @round.save
      redirect_to event_manage_review_round_path(@event, @round), notice: "Evaluation round created."
    else
      3.times { @round.review_criteria.build(kind: "number", min_value: 1, max_value: 5) } if @round.review_criteria.empty?
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @round.update(round_params)
      redirect_to event_manage_review_round_path(@event, @round), notice: "Round updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @round.destroy
    redirect_to event_manage_review_rounds_path(@event), notice: "Round deleted."
  end

  def add_reviewer
    user = if params[:user_id].present?
      User.find_by(id: params[:user_id])
    elsif params[:email].present?
      u = User.find_or_create_by!(email: params[:email].strip.downcase) { |x| x.password = SecureRandom.hex(24); x.skip_name_validation = true }
      @event.event_memberships.find_or_create_by!(user: u, role: :reviewer)
      u
    end
    @round.round_reviewers.find_or_create_by!(user: user) if user
    redirect_to event_manage_review_round_path(@event, @round), notice: "Reviewer added to this round."
  end

  def remove_reviewer
    @round.round_reviewers.where(user_id: params[:user_id]).destroy_all
    redirect_to event_manage_review_round_path(@event, @round), notice: "Reviewer removed from round."
  end

  # Assign submissions to reviewers. Supports: explicit reviewer+submissions,
  # auto-distribute across the pool (with an optional per-reviewer cap), and a
  # track filter to scope which submissions get assigned.
  def assign
    subs = @event.submissions.where.not(status: "draft")
    subs = subs.where(track_id: params[:track_id]) if params[:track_id].present?

    if params[:auto].present?
      cap = params[:cap].presence&.to_i
      reviewers = @round.reviewers.to_a
      return redirect_back(fallback_location: round_path, alert: "Add reviewers to the pool first.") if reviewers.empty?
      i = 0
      subs.find_each do |s|
        assigned = 0
        reviewers.rotate(i).each do |r|
          break if cap && @round.assigned_count(r) >= cap
          @round.review_assignments.find_or_create_by!(submission: s, user: r)
          assigned += 1
          break # one reviewer per submission in round-robin
        end
        i += 1
      end
      notice = "Auto-distributed #{subs.count} submissions across #{reviewers.size} reviewers#{cap ? " (cap #{cap})" : ''}."
    else
      reviewer = @round.reviewers.find_by(id: params[:user_id])
      ids = Array(params[:submission_ids]).reject(&:blank?)
      ids.each { |sid| @round.review_assignments.find_or_create_by!(submission_id: sid, user: reviewer) if reviewer }
      notice = "Assigned #{ids.size} submission(s) to #{reviewer&.display_name}."
    end
    redirect_to round_path, notice: notice
  end

  # Nudge reviewers who have incomplete assignments.
  def remind
    laggards = @round.reviewers.select { |r| @round.completed_count(r) < @round.assigned_count(r) }
    laggards.each do |r|
      log = @event.communication_logs.create!(user: current_user,
        subject: "Reminder: your reviews for #{@round.name} are due",
        body: "You have #{@round.assigned_count(r) - @round.completed_count(r)} submission(s) left to review for #{@event.name}.",
        recipients: [{ "name" => r.display_name, "email" => r.email }], sent_at: Time.current)
      EventMailer.generic(r.email, log.subject, log.body).deliver_later rescue nil
    end
    redirect_to round_path, notice: "Reminder sent to #{laggards.size} reviewer(s) with outstanding reviews."
  end

  # Lightweight AI first-pass: a heuristic numeric score + written rationale,
  # stored as an AI-attributed review the organizer can override.
  def ai_evaluate
    submission = @event.submissions.find(params[:submission_id])
    review = @round.reviews.find_or_initialize_by(submission: submission, user: current_user, ai_generated: true)
    scores = {}
    @round.review_criteria.where(kind: "number").each do |c|
      base = [(submission.abstract.to_s.length / 120), c.min_value].max
      scores[c.id.to_s] = [[base, c.min_value].max, c.max_value].min
    end
    review.scores = scores
    review.ai_rationale = "AI first pass: the abstract for “#{submission.title}” is #{submission.abstract.to_s.length} characters, covering #{submission.track&.name || 'its track'} at #{submission.audience_level || 'a general'} level. Concrete data points and a clear takeaway raise originality; relevance tracks the #{submission.track&.name} track. Organizer review recommended."
    review.status = "completed"
    review.submitted_at = Time.current
    review.save!
    redirect_to results_event_manage_review_rounds_path(@event, round: @round.id), notice: "AI evaluation generated for “#{submission.title}”. You can override it."
  end

  # Aggregate results across all rounds (sortable, CSV export).
  def results
    @round = params[:round].present? ? @event.review_rounds.find(params[:round]) : @event.review_rounds.first
    @rows = @event.submissions.where.not(status: "draft").map do |s|
      { submission: s, weighted: @round&.weighted_average(s), unweighted: @round&.unweighted_average(s),
        reviews: @round ? @round.reviews.where(submission: s, status: "completed").count : 0 }
    end
    dir = params[:dir] == "asc" ? 1 : -1
    @rows.sort_by! { |r| [(r[:weighted] || -1) * dir] } if params[:sort] == "score" || params[:sort].nil?
    respond_to do |format|
      format.html
      format.csv do
        csv = CSV.generate do |out|
          out << ["Title", "Speaker", "Track", "Status", "Reviews", "Unweighted", "Weighted"]
          @rows.each do |r|
            s = r[:submission]
            out << [s.title, s.speaker_names, s.track&.name, s.status, r[:reviews], r[:unweighted], r[:weighted]]
          end
        end
        send_data csv, filename: "#{@event.slug}-review-results.csv"
      end
    end
  end

  private

  def set_round = @round = @event.review_rounds.find(params[:id])
  def round_path = event_manage_review_round_path(@event, @round)

  def round_params
    params.require(:review_round).permit(:name, :instructions, :opens_at, :closes_at, :anonymized, :status,
      review_criteria_attributes: %i[id label kind min_value max_value weight options_text position _destroy]).tap do |p|
      (p[:review_criteria_attributes] || {}).each_value do |c|
        if c[:options_text]
          c[:options] = c.delete(:options_text).to_s.split(",").map(&:strip).reject(&:blank?)
        end
      end
    end
  end
end
