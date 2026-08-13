class Manage::SubmissionFormsController < Manage::BaseController
  before_action :set_form, only: %i[show edit update destroy]

  def index
    @forms = @event.submission_forms
    @event.cfp_form if @forms.empty?   # auto-provision a default form
    @forms = @event.submission_forms.reload
  end

  def show; end

  def new = @form = @event.submission_forms.new(title: "Submit a session to #{@event.name}")
  def edit; end

  def create
    @form = @event.submission_forms.new(form_params)
    if @form.save
      redirect_to event_manage_submission_form_path(@event, @form), notice: "Form created. Add your questions."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @form.update(form_params)
      redirect_to event_manage_submission_form_path(@event, @form), notice: "Form saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @form.destroy
    redirect_to event_manage_submission_forms_path(@event), notice: "Form deleted."
  end

  private

  def set_form = @form = @event.submission_forms.find(params[:id])
  def form_params
    params.require(:submission_form).permit(:name, :title, :welcome_message, :confirmation_message, :closes_at, :published)
  end
end
