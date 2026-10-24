import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "consent", "button", "status"]
  connect() { this.validate() }
  validate() {
    this.buttonTarget.disabled = !(this.emailTarget.validity.valid && this.consentTarget.checked)
  }
  submit(event) {
    event.preventDefault()
    this.statusTarget.textContent = "Отправка подписки ещё не подключена. Адрес не отправлен и не сохранён."
  }
}
