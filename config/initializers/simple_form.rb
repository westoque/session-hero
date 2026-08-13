# frozen_string_literal: true

# simple_form is the default form builder for this app. Wrappers below map
# simple_form's input types onto daisyUI v5 form markup:
#   <fieldset class="fieldset">
#     <label class="fieldset-legend">…</label>
#     <input class="input w-full">        (select / textarea / checkbox variants)
#     <p class="label text-error">…errors…</p>
#   </fieldset>
SimpleForm.setup do |config|
  # Text-like inputs (string, email, password, number, date via input_html type…)
  config.wrappers :daisy, tag: :fieldset, class: "fieldset",
                  error_class: "has-error" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "fieldset-legend"
    b.use :input, class: "input w-full", error_class: "input-error"
    b.use :error, wrap_with: { tag: :p, class: "label text-error text-sm" }
    b.use :hint,  wrap_with: { tag: :p, class: "label text-xs opacity-60" }
  end

  config.wrappers :daisy_select, tag: :fieldset, class: "fieldset",
                  error_class: "has-error" do |b|
    b.use :html5
    b.use :label, class: "fieldset-legend"
    b.use :input, class: "select w-full", error_class: "select-error"
    b.use :error, wrap_with: { tag: :p, class: "label text-error text-sm" }
    b.use :hint,  wrap_with: { tag: :p, class: "label text-xs opacity-60" }
  end

  config.wrappers :daisy_textarea, tag: :fieldset, class: "fieldset",
                  error_class: "has-error" do |b|
    b.use :html5
    b.use :placeholder
    b.use :label, class: "fieldset-legend"
    b.use :input, class: "textarea w-full", error_class: "textarea-error"
    b.use :error, wrap_with: { tag: :p, class: "label text-error text-sm" }
    b.use :hint,  wrap_with: { tag: :p, class: "label text-xs opacity-60" }
  end

  config.wrappers :daisy_boolean, tag: :fieldset, class: "fieldset",
                  error_class: "has-error" do |b|
    b.use :html5
    b.wrapper tag: :label, class: "label cursor-pointer justify-start gap-2" do |ba|
      ba.use :input, class: "checkbox checkbox-primary"
      ba.use :label_text
    end
    b.use :error, wrap_with: { tag: :p, class: "label text-error text-sm" }
    b.use :hint,  wrap_with: { tag: :p, class: "label text-xs opacity-60" }
  end

  config.default_wrapper  = :daisy
  config.wrapper_mappings  = {
    boolean:  :daisy_boolean,
    select:   :daisy_select,
    text:     :daisy_textarea,
  }

  # Error summary banner rendered by f.error_notification, styled as a daisyUI alert.
  config.error_notification_tag   = :div
  config.error_notification_class = "alert alert-error mb-4"

  # Only add simple_form's auto CSS classes (input type / required / optional) to
  # the actual input — NOT the wrapper or label. Otherwise a select input's
  # wrapper <fieldset> and its <label> each get a bare `select` class, which
  # collides with daisyUI's `.select` component and renders extra select-styled
  # boxes (doubled chevrons) around the real <select>.
  config.generate_additional_classes_for = %i[input]

  config.button_class      = "btn"
  config.boolean_style     = :nested
  config.browser_validations = false
  config.boolean_label_class = "label-text"
end
