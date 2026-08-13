class Crm::SegmentsController < Crm::BaseController
  def index
    @segments = current_user.segments
  end

  def create
    criteria = params.fetch(:criteria, {}).permit(:q, :company, :speaker_type, :tag).to_h
    criteria.reject! { |_, v| v.blank? }
    segment = current_user.segments.new(name: params[:name], criteria: criteria)
    if segment.save
      redirect_to crm_contacts_path(criteria), notice: "Saved segment “#{segment.name}”."
    else
      redirect_to crm_contacts_path(criteria), alert: "Give the segment a name."
    end
  end

  def destroy
    current_user.segments.find(params[:id]).destroy
    redirect_to crm_segments_path, notice: "Segment removed."
  end
end
