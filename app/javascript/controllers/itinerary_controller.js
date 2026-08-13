import { Controller } from "@hotwired/stimulus"

// Personal schedule: add/remove sessions, persist in localStorage (no login),
// and live-render the "My Schedule" list. State survives full page reloads.
export default class extends Controller {
  static targets = ["button", "item", "count", "empty"]
  static values = { key: String }

  connect() {
    this.ids = new Set(this.load())
    this.refresh()
  }

  get storageKey() {
    return this.keyValue || "os-itinerary"
  }

  load() {
    try {
      return JSON.parse(localStorage.getItem(this.storageKey) || "[]")
    } catch (e) {
      return []
    }
  }

  save() {
    localStorage.setItem(this.storageKey, JSON.stringify([...this.ids]))
  }

  toggle(event) {
    const id = String(event.currentTarget.dataset.sessionId)
    if (this.ids.has(id)) {
      this.ids.delete(id)
    } else {
      this.ids.add(id)
    }
    this.save()
    this.refresh()
  }

  // Reflect current state onto buttons, my-schedule items, and the count.
  refresh() {
    this.buttonTargets.forEach((btn) => {
      const added = this.ids.has(String(btn.dataset.sessionId))
      btn.classList.toggle("btn-primary", added)
      btn.classList.toggle("btn-outline", !added)
      const label = btn.querySelector(".itin-label")
      if (label) label.textContent = added ? "Added ✓" : "★ Add to schedule"
    })

    let n = 0
    this.itemTargets.forEach((item) => {
      const added = this.ids.has(String(item.dataset.sessionId))
      item.classList.toggle("hidden", !added)
      if (added) n++
    })

    this.countTargets.forEach((el) => (el.textContent = n))
    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", n > 0)
  }
}
