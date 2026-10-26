import { Controller } from "@hotwired/stimulus"

const clamp = value => Math.max(0, Math.min(1, value))

export default class extends Controller {
  static targets = ["intro", "history", "maps", "mapFrame"]

  connect() {
    this.motion = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.schedule = () => {
      if (!this.frame) this.frame = requestAnimationFrame(() => { this.frame = null; this.paint() })
    }
    this.element.addEventListener("scroll", this.schedule, { passive: true })
    this.motion.addEventListener("change", this.schedule)
    this.observer = new ResizeObserver(this.schedule)
    this.observer.observe(this.element)
    this.paint()
    document.fonts.ready.then(() => { if (this.element.isConnected) this.schedule() })
  }

  progress(section) {
    const viewport = this.element.clientHeight
    return clamp((this.element.scrollTop - section.offsetTop) / Math.max(1, section.offsetHeight - viewport))
  }

  paint() {
    const reduced = this.motion.matches
    const intro = reduced ? 1 : this.progress(this.introTarget)
    this.introTarget.style.setProperty("--intro-progress", intro)
    this.introTarget.style.setProperty("--title-drop", `${intro * 62}px`)
    this.introTarget.style.setProperty("--bridge-width", `${26 + intro * 74}%`)
    const history = reduced ? 1 : this.progress(this.historyTarget)
    this.historyTarget.querySelectorAll(".about-image").forEach((image, index) => {
      const phase = clamp((history - index * .065) / .65)
      image.style.setProperty("--image-x", `${(phase - .5) * 64}px`)
      image.style.setProperty("--image-y", `${(phase - .5) * 80 + index * 12}px`)
      image.style.setProperty("--image-opacity", reduced ? 1 : clamp(phase * 3))
    })
    const maps = reduced ? 0 : this.progress(this.mapsTarget)
    const reveal = clamp((maps - .3) / .4)
    this.mapsTarget.style.setProperty("--map-reveal", reveal)
    this.mapsTarget.style.setProperty("--map-rise", `${(1 - reveal) * 90}px`)
    this.mapFrameTargets.forEach((section, index) => {
      const hidden = !reduced && (index === 0 ? reveal > .6 : reveal <= .6)
      section.inert = hidden
      section.setAttribute("aria-hidden", String(hidden))
    })
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.schedule)
    this.motion.removeEventListener("change", this.schedule)
    this.observer.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }
}
