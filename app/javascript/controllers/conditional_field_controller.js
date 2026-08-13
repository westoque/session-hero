import { Controller } from "@hotwired/stimulus"

// Shows/hides form fields that declare data-show-when="<value>" based on the
// current value of the trigger <select> (the format question on the CFP form).
export default class extends Controller {
  static targets = ["trigger", "dependent"]

  connect() { this.toggle() }

  toggle() {
    const value = this.hasTriggerTarget ? this.triggerTarget.value : null
    this.dependentTargets.forEach((el) => {
      const showWhen = el.dataset.showWhen
      el.classList.toggle("hidden", showWhen !== value)
    })
  }
}
