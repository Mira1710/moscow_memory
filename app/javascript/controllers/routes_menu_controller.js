import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  toggle() {
    const open = this.element.classList.toggle("routes-menu-open")
    this.buttonTarget.setAttribute("aria-expanded", String(open))
    this.buttonTarget.setAttribute("aria-label", open ? "Закрыть меню" : "Открыть меню")
  }
  close() {
    this.element.classList.remove("routes-menu-open")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.setAttribute("aria-label", "Открыть меню")
  }
}
