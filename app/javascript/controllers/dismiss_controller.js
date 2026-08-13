import { Controller } from "@hotwired/stimulus"

// Removes its element when the dismiss action fires — used by the flash
// message close (×) button.
export default class extends Controller {
  remove() {
    this.element.remove()
  }
}
