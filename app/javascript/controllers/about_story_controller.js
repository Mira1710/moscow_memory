import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scene"]

  connect() {
    this.motion = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.schedule = () => {
      if (!this.frame) this.frame = requestAnimationFrame(() => { this.frame = null; this.paint() })
    }
    this.measure = () => {
      const viewport = this.element.clientHeight
      this.sceneTargets.forEach(scene => {
        const top = Math.min(0, viewport - scene.offsetHeight)
        scene.style.setProperty("--scene-top", `${top}px`)
      })
      this.schedule()
    }
    this.element.addEventListener("scroll", this.schedule, { passive: true })
    this.motion.addEventListener("change", this.measure)
    this.observer = new ResizeObserver(this.measure)
    this.observer.observe(this.element)
    this.sceneTargets.forEach(scene => this.observer.observe(scene))
    this.measure()
    document.fonts.ready.then(() => { if (this.element.isConnected) this.measure() })
  }

  paint() {
    const top = this.element.getBoundingClientRect().top
    const viewport = this.element.clientHeight
    this.sceneTargets.forEach((scene, index) => {
      const next = this.sceneTargets[index + 1]
      const overlap = next ? Math.max(0, Math.min(1, 1 - (next.getBoundingClientRect().top - top) / viewport)) : 0
      scene.style.setProperty("--depth-offset", this.motion.matches ? "0px" : `${-overlap * 24}px`)
    })
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.schedule)
    this.motion.removeEventListener("change", this.measure)
    this.observer.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }
}
