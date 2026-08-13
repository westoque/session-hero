class Crm::PipelineController < Crm::BaseController
  def index
    @stages = Contact::STAGES
    enrolled = current_user.contacts.where.not(pipeline_stage: nil)
    @by_stage = @stages.index_with { |stage| enrolled.select { |c| c.pipeline_stage == stage } }
    @total_enrolled = enrolled.count
  end
end
