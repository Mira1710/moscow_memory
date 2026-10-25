import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["email", "consent", "button", "status", "dialog"]

  connect() { this.pending = false; this.validate() }
  disconnect() { this.request?.abort(); if (this.dialogTarget.open) this.dialogTarget.close() }

  validate() {
    this.buttonTarget.disabled = this.pending || !(this.emailTarget.validity.valid && this.consentTarget.checked)
  }

  async submit(event) {
    event.preventDefault()
    const form = event.currentTarget
    if (this.pending || !form.reportValidity()) return
    this.pending = true
    this.validate()
    this.statusTarget.textContent = "Сохраняем вашу почту…"
    form.setAttribute("aria-busy", "true")
    this.request = new AbortController()
    try {
      const response = await fetch(form.action, {
        method: "POST",
        headers: { "Accept": "application/json", "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content || "" },
        body: new FormData(form),
        signal: this.request.signal
      })
      const data = await response.json().catch(() => ({}))
      if (!response.ok || !data.saved) throw new Error(data.error || "Не удалось сохранить почту. Попробуйте ещё раз.")
      form.reset()
      this.statusTarget.textContent = "Почта сохранена. Спасибо за интерес!"
      this.dialogTarget.showModal()
    } catch (error) {
      if (error.name !== "AbortError") this.statusTarget.textContent = error instanceof TypeError ? "Нет соединения. Почта не сохранена — попробуйте ещё раз." : error.message
    } finally {
      this.pending = false
      form.removeAttribute("aria-busy")
      this.validate()
    }
  }

  close() { this.dialogTarget.close(); this.emailTarget.focus({ preventScroll: true }) }
}
