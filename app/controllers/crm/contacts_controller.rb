class Crm::ContactsController < Crm::BaseController
  before_action :set_contact, only: %i[show edit update destroy enroll move_stage merge_into add_to_event]

  def index
    @contacts = apply_filters(current_user.contacts)
    @companies      = current_user.contacts.where.not(company: [nil, ""]).distinct.pluck(:company).sort
    @speaker_types  = current_user.contacts.where.not(speaker_type: [nil, ""]).distinct.pluck(:speaker_type).sort
    @all_tags       = current_user.contacts.flat_map(&:tag_list).uniq.sort
    @segments       = current_user.segments
    @filters        = current_filters
  end

  def show
    @notes      = @contact.contact_notes.includes(:user)
    @duplicates = current_user.contacts
      .where("lower(name) = ? AND id <> ?", @contact.name.to_s.downcase, @contact.id)
    @connected_events = EventSpeaker
      .where("lower(email) = ?", @contact.email.to_s.downcase)
      .includes(:event)
    @organizing_events = current_user.organizing_events.order(:name)
  end

  def new
    @contact = current_user.contacts.new
  end

  def create
    @contact = current_user.contacts.new(contact_params)
    if @contact.save
      redirect_to crm_contact_path(@contact), notice: "Contact created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to crm_contact_path(@contact), notice: "Contact updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to crm_contacts_path, notice: "Contact deleted."
  end

  # ---- Pipeline ----------------------------------------------------------

  def enroll
    @contact.update(
      pipeline_stage: params[:stage].presence || "Identified",
      pipeline_score: params[:pipeline_score].presence,
      pipeline_rationale: params[:pipeline_rationale].presence
    )
    @contact.contact_notes.create!(
      user: current_user, author_name: current_user.display_name,
      kind: "stage_change", body: "Enrolled in pipeline at #{@contact.pipeline_stage}"
    )
    redirect_back fallback_location: crm_contact_path(@contact), notice: "Enrolled in pipeline."
  end

  def move_stage
    stage = params[:stage]
    if Contact::STAGES.include?(stage)
      @contact.update(pipeline_stage: stage)
      @contact.contact_notes.create!(
        user: current_user, author_name: current_user.display_name,
        kind: "stage_change", body: "Moved to #{stage}"
      )
      notice = "Moved to #{stage}."
    else
      notice = "Unknown stage."
    end
    redirect_back fallback_location: crm_pipeline_path, notice: notice
  end

  # ---- Merge -------------------------------------------------------------

  def merge_into
    dup = current_user.contacts.find_by(id: params[:duplicate_id])
    if dup && dup.id != @contact.id
      # Fill any blank field on the primary from the duplicate.
      %i[email company job_title bio speaker_type pipeline_stage pipeline_score pipeline_rationale].each do |attr|
        @contact[attr] = dup[attr] if @contact[attr].blank? && dup[attr].present?
      end
      merged_tags = (@contact.tag_list + dup.tag_list).uniq
      @contact.tags = merged_tags
      @contact.custom = (dup.custom || {}).merge(@contact.custom || {})
      @contact.save!
      dup.contact_notes.update_all(contact_id: @contact.id)
      dup.destroy
      redirect_to crm_contact_path(@contact), notice: "Merged duplicate into #{@contact.name}."
    else
      redirect_to crm_contact_path(@contact), alert: "Could not merge."
    end
  end

  # ---- Handoff to an event ----------------------------------------------

  def add_to_event
    event = current_user.organizing_events.find_by(id: params[:event_id])
    if event
      event.event_speakers.create!(
        name: @contact.name, email: @contact.email, title: @contact.job_title,
        company: @contact.company, bio: @contact.bio, status: "invited"
      )
      redirect_to crm_contact_path(@contact), notice: "Added #{@contact.name} to #{event.name}."
    else
      redirect_to crm_contact_path(@contact), alert: "Select one of your events."
    end
  end

  # ---- Import ------------------------------------------------------------

  def import
    return unless request.post?

    file = params[:file]
    if file.blank?
      redirect_to import_crm_contacts_path, alert: "Choose a CSV file to upload."
      return
    end

    rows = parse_csv(file.read)
    if rows.empty?
      redirect_to import_crm_contacts_path, alert: "That CSV had no data rows."
      return
    end

    imported = 0
    skipped  = 0
    rows.each do |row|
      name = row["name"].to_s.strip
      next if name.blank?

      email = row["email"].to_s.strip
      existing = email.present? && current_user.contacts.find_by("lower(email) = ?", email.downcase)
      if existing
        skipped += 1
        next
      end
      current_user.contacts.create!(
        name: name, email: email,
        job_title: row["title"].to_s.strip, company: row["company"].to_s.strip,
        bio: row["bio"].to_s.strip
      )
      imported += 1
    end

    redirect_to crm_contacts_path, notice: "Imported #{imported} contact(s), skipped #{skipped}."
  end

  # ---- Bulk email --------------------------------------------------------

  def bulk_email
    ids       = Array(params[:contact_ids]).reject(&:blank?)
    @selected = current_user.contacts.where(id: ids)
    subject   = params[:subject].to_s
    body      = params[:body].to_s

    if @selected.empty?
      redirect_to crm_contacts_path, alert: "Select at least one contact to email."
      return
    end

    recipients = @selected.map do |c|
      first_name = c.name.to_s.split.first.to_s
      { name: c.name, email: c.email,
        subject: resolve_tags(subject, c, first_name),
        body: resolve_tags(body, c, first_name) }
    end

    CommunicationLog.create!(
      user: current_user, kind: "email", subject: subject, body: body,
      recipients: recipients, sent_at: Time.current
    )

    redirect_to crm_contacts_path, notice: "Email logged to #{recipients.size} recipient(s)."
  end

  private

  def set_contact
    @contact = current_user.contacts.find(params[:id])
  end

  def contact_params
    permitted = params.require(:contact).permit(
      :name, :email, :company, :job_title, :bio, :speaker_type, :tags
    )
    if permitted.key?(:tags)
      permitted[:tags] = permitted[:tags].to_s.split(",").map(&:strip).reject(&:blank?)
    end
    permitted
  end

  def current_filters
    { q: params[:q], company: params[:company],
      speaker_type: params[:speaker_type], tag: params[:tag] }.reject { |_, v| v.blank? }
  end

  def apply_filters(scope)
    if params[:q].present?
      term = "%#{params[:q].to_s.downcase}%"
      scope = scope.where(
        "lower(name) LIKE :t OR lower(email) LIKE :t OR lower(company) LIKE :t", t: term
      )
    end
    scope = scope.where(company: params[:company]) if params[:company].present?
    scope = scope.where(speaker_type: params[:speaker_type]) if params[:speaker_type].present?
    if params[:tag].present?
      tag = params[:tag]
      scope = scope.select { |c| c.tag_list.include?(tag) }
    end
    scope
  end

  # Minimal RFC-4180-ish CSV parser (Ruby 3.4 dropped the bundled `csv` gem and
  # it isn't in the Gemfile). Handles quoted fields, embedded commas/newlines,
  # and doubled-quote escapes. Returns an array of hashes keyed by header.
  def parse_csv(text)
    text = text.to_s.dup.force_encoding("UTF-8").scrub.delete("\r")
    records = []
    field = +""
    row = []
    in_quotes = false
    i = 0
    chars = text.chars
    while i < chars.length
      ch = chars[i]
      if in_quotes
        if ch == '"'
          if chars[i + 1] == '"'
            field << '"'
            i += 1
          else
            in_quotes = false
          end
        else
          field << ch
        end
      else
        case ch
        when '"' then in_quotes = true
        when ',' then row << field; field = +""
        when "\n" then row << field; records << row; row = []; field = +""
        else field << ch
        end
      end
      i += 1
    end
    row << field unless field.empty? && row.empty?
    records << row unless row.empty? && field.empty?

    return [] if records.empty?

    headers = records.shift.map { |h| h.to_s.strip.downcase }
    records.map do |values|
      next nil if values.all? { |v| v.to_s.strip.empty? }
      headers.each_with_index.to_h { |h, idx| [h, values[idx]] }
    end.compact
  end

  def resolve_tags(text, contact, first_name)
    text.to_s
      .gsub("{{first_name}}", first_name)
      .gsub("{{name}}", contact.name.to_s)
      .gsub("{{company}}", contact.company.to_s)
  end
end
