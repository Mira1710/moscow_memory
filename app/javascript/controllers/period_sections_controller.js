import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["section"]
  connect() { this.refresh() }
  toggle() { this.refresh() }
  refresh() {
    this.sectionTargets.forEach(section => {
      const checkbox = this.element.querySelector(`input[type="checkbox"][data-section-key="${section.dataset.sectionKey}"]`)
      section.hidden = !checkbox.checked
    })
  }
}
