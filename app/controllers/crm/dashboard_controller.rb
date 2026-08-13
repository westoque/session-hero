class Crm::DashboardController < Crm::BaseController
  def index
    @contacts       = current_user.contacts
    @total          = @contacts.count
    @enrolled       = @contacts.where.not(pipeline_stage: nil).count
    @segments_count = current_user.segments.count

    # Analytics widgets computed straight from the same directory data so the
    # numbers always reconcile with contacts#index.
    @top_companies = @contacts
      .where.not(company: [nil, ""])
      .group(:company).order("count_all desc").limit(5).count

    @by_speaker_type = @contacts
      .group(:speaker_type).order("count_all desc").count
      .transform_keys { |k| k.presence || "Unspecified" }

    @by_stage = @contacts.where.not(pipeline_stage: nil).group(:pipeline_stage).count

    @recent_logs = CommunicationLog.where(user: current_user).limit(5)
  end
end
