class Manage::FormFieldsController < Manage::BaseController
  before_action :set_form
  before_action :set_field, only: %i[update destroy]

  def create
    field = @form.form_fields.new(field_params)
    field.position = @form.form_fields.count
    field.save
    redirect_to event_manage_submission_form_path(@event, @form), notice: "Question added."
  end

  def update
    @field.update(field_params)
    redirect_to event_manage_submission_form_path(@event, @form), notice: "Question updated."
  end

  def destroy
    @field.destroy
    redirect_to event_manage_submission_form_path(@event, @form), notice: "Question removed."
  end

  private

  def set_form  = @form = @event.submission_forms.find(params[:submission_form_id])
  def set_field = @field = @form.form_fields.find(params[:id])

  def field_params
    p = params.require(:form_field).permit(:label, :field_type, :required, :help_text,
      :options_text, :conditional_field_id, :conditional_value)
    if p[:options_text]
      p[:options] = p.delete(:options_text).to_s.split("\n").map(&:strip).reject(&:blank?)
    end
    p
  end
end
