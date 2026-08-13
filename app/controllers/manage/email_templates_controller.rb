class Manage::EmailTemplatesController < Manage::BaseController
  before_action :set_template, only: %i[edit update destroy]

  def index
    @templates = @event.email_templates
  end

  def new = @template = @event.email_templates.new
  def edit; end

  def create
    @template = @event.email_templates.new(template_params)
    if @template.save
      redirect_to event_manage_email_templates_path(@event), notice: "Template created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @template.update(template_params)
      redirect_to event_manage_email_templates_path(@event), notice: "Template updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @template.destroy
    redirect_to event_manage_email_templates_path(@event), notice: "Template deleted."
  end

  private

  def set_template = @template = @event.email_templates.find(params[:id])
  def template_params = params.require(:email_template).permit(:name, :subject, :body)
end
