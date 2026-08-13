import { Controller } from "@hotwired/stimulus"

// GitHub-style copy button: copies data-clipboard-text (or the source field's
// value) to the clipboard, then briefly swaps the copy icon for a check.
export default class extends Controller {
  static targets = ["source", "copyIcon", "checkIcon"]
  static values = { text: String }

  copy(event) {
    event.preventDefault()
    const text = this.textValue || (this.hasSourceTarget ? this.sourceTarget.value : "")
    if (!text) return

    navigator.clipboard.writeText(text).then(() => this.flash())
  }

  flash() {
    if (!this.hasCopyIconTarget || !this.hasCheckIconTarget) return
    this.copyIconTarget.classList.add("hidden")
    this.checkIconTarget.classList.remove("hidden")
    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.checkIconTarget.classList.add("hidden")
      this.copyIconTarget.classList.remove("hidden")
    }, 1500)
  }
}
