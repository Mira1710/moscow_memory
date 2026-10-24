import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template", "period"]
  connect() { this.sequence = Date.now() }
  add() {
    this.sequence += 1
    const html = this.templateTarget.innerHTML.replaceAll("NEW_PERIOD", String(this.sequence))
    this.listTarget.insertAdjacentHTML("beforeend", html)
    this.listTarget.lastElementChild.querySelector('input[type="text"]')?.focus()
  }
  remove(event) {
    const period = event.currentTarget.closest(".editor-period")
    if (period.querySelector('input[name$="[id]"]')) {
      period.querySelector("[data-period-destroy]").value = "1"
      period.hidden = true
    } else period.remove()
  }
}
