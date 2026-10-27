import { Controller } from "@hotwired/stimulus"

const clamp = value => Math.max(0, Math.min(1, value))

export default class extends Controller {
  static targets = ["intro", "history", "maps", "mapFrame", "slides", "slideLabel"]

  connect() {
    this.mobile = window.matchMedia("(max-width: 767px)")
    this.motion = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.schedule = () => {
      if (!this.frame) this.frame = requestAnimationFrame(() => { this.frame = null; this.paint() })
    }
    this.element.addEventListener("scroll", this.schedule, { passive: true })
    this.motion.addEventListener("change", this.schedule)
    this.mobile.addEventListener("change", this.schedule)
    this.observer = new ResizeObserver(this.schedule)
    this.observer.observe(this.element)
    this.paint()
    document.fonts.ready.then(() => { if (this.element.isConnected) this.schedule() })
  }

  progress(section) {
    const viewport = this.element.clientHeight
    return clamp((this.element.scrollTop - section.offsetTop) / Math.max(1, section.offsetHeight - viewport))
  }

  slideChanged() {
    const index = Math.round(this.slidesTarget.scrollLeft / Math.max(1, this.slidesTarget.clientWidth))
    this.slideLabelTarget.textContent = `${index + 1} / 2`
  }

  moveSlide(direction) {
    this.slidesTarget.scrollBy({ left: this.slidesTarget.clientWidth * direction, behavior: this.motion.matches ? "instant" : "smooth" })
  }

  previousSlide() { this.moveSlide(-1) }
  nextSlide() { this.moveSlide(1) }

  slideKey(event) {
    if (event.key === "ArrowRight") { event.preventDefault(); this.nextSlide() }
    if (event.key === "ArrowLeft") { event.preventDefault(); this.previousSlide() }
  }

  paint() {
    if (this.mobile.matches) {
      this.mapFrameTargets.forEach(section => { section.inert = false; section.setAttribute("aria-hidden", "false") })
      return
    }
    const reduced = this.motion.matches
    const intro = reduced ? 1 : this.progress(this.introTarget)
    this.introTarget.style.setProperty("--intro-progress", intro)
    this.introTarget.style.setProperty("--title-drop", `${intro * 62}px`)
    this.introTarget.style.setProperty("--bridge-width", `${26 + intro * 74}%`)
    const history = reduced ? 1 : this.progress(this.historyTarget)
    const group = this.historyTarget.querySelector(".about-evidence-grid")
    group.style.setProperty("--group-x", `${history * 100}px`)
    group.style.setProperty("--group-y", `${history * 100}px`)
    group.style.setProperty("--group-opacity", reduced ? 1 : clamp(history * 6))
    const maps = reduced ? 0 : this.progress(this.mapsTarget)
    const second = clamp((maps - .2) / .25)
    const third = clamp((maps - .6) / .25)
    const active = third > .6 ? 2 : second > .6 ? 1 : 0
    this.mapFrameTargets.forEach((section, index) => {
      const reveal = index === 0 ? 1 : index === 1 ? second : third
      const opacity = index === 0 ? 1 - second : index === 1 ? second * (1 - third) : third
      section.style.setProperty("--frame-opacity", reduced ? 1 : opacity)
      section.style.setProperty("--frame-rise", `${(1 - reveal) * 90}px`)
      const hidden = !reduced && index !== active
      section.inert = hidden
      section.setAttribute("aria-hidden", String(hidden))
    })
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.schedule)
    this.motion.removeEventListener("change", this.schedule)
    this.mobile.removeEventListener("change", this.schedule)
    this.observer.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }
}
