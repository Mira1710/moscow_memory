import { Controller } from "@hotwired/stimulus"

let apiPromise
function loadMaps(key) {
  if (window.ymaps) return new Promise((resolve, reject) => window.ymaps.ready(() => resolve(window.ymaps), reject))
  if (!apiPromise) {
    apiPromise = new Promise((resolve, reject) => {
      const script = document.createElement("script")
      const timer = setTimeout(() => fail(), 20000)
      const fail = () => { clearTimeout(timer); script.remove(); apiPromise = null; reject(new Error("Maps API unavailable")) }
      script.src = `https://api-maps.yandex.ru/2.1/?apikey=${encodeURIComponent(key)}&lang=ru_RU`
      script.onload = () => {
        if (!window.ymaps) return fail()
        window.ymaps.ready(() => { clearTimeout(timer); resolve(window.ymaps) }, fail)
      }
      script.onerror = fail
      document.head.append(script)
    })
  }
  return apiPromise
}

export default class extends Controller {
  static targets = ["map", "status", "article", "body", "scroll", "close", "place", "year", "yearLabel", "allYears", "years", "sources", "placePeriods"]
  static values = { key: String }

  connect() {
    this.disposed = false
    this.markers = new Map()
    this.historyMode = false
    this.step = 10
    this.renderYears()
    this.filter()
    if (window.matchMedia("(max-width: 767px)").matches) {
      this.element.querySelectorAll(".panel-toggle").forEach(button => {
        const panel = this.element.querySelector(`#${button.getAttribute("aria-controls")}`)
        panel.hidden = false
        button.setAttribute("aria-expanded", "true")
        button.querySelector("span").textContent = "−"
      })
    }
    this.start()
    this.onViewportChange = () => { this.closeMenu(); this.renderYears() }
    window.addEventListener("resize", this.onViewportChange)
  }

  async start() {
    if (!this.keyValue.trim()) {
      this.statusTarget.textContent = "Карта будет доступна после настройки API-ключа. Материалы доступны в архиве."
      return
    }
    try {
      const ymaps = await loadMaps(this.keyValue)
      if (this.disposed) return
      this.map = new ymaps.Map(this.mapTarget, { center: [55.7558, 37.6176], zoom: 12, controls: ["zoomControl"] })
      this.map.behaviors.disable("scrollZoom")
      this.mapResizeObserver = new ResizeObserver(() => this.map?.container?.fitToViewport())
      this.mapResizeObserver.observe(this.mapTarget)
      this.placeTargets.forEach(template => {
        const { latitude, longitude, placeId } = template.dataset
        if (!latitude.trim() || !longitude.trim()) return
        const coords = [Number(latitude), Number(longitude)]
        if (!coords.every(Number.isFinite) || Math.abs(coords[0]) > 90 || Math.abs(coords[1]) > 180) return
        const icon = template.dataset.icon
        const options = icon ? { iconLayout: "default#image", iconImageHref: icon, iconImageSize: [44, 44], iconImageOffset: [-22, -22], openBalloonOnClick: false } : { preset: "islands#redDotIcon", openBalloonOnClick: false }
        const marker = new ymaps.Placemark(coords, {}, options)
        marker.events.add("click", () => this.show(placeId))
        this.markers.set(placeId, marker)
      })
      this.statusTarget.hidden = true
      this.filter()
    } catch (_) {
      if (!this.disposed) this.statusTarget.textContent = "Не удалось загрузить Яндекс Карты. Проверьте соединение и настройки ключа. Материалы доступны в архиве."
    }
  }

  matches(data) {
    const year = Number(this.yearTarget.value)
    return (!data.from || Number(data.from) <= year) && (!data.to || Number(data.to) >= year)
  }

  renderYears() {
    const current = new Date().getFullYear()
    const selected = Number(this.yearTarget.value)
    const start = this.step === 1 ? Math.min(selected - 4, current - 9) : this.step === 50 ? 1900 : window.matchMedia("(max-width: 767px)").matches ? 2000 : 1940
    const end = this.step === 1 ? Math.min(start + 9, current) : current
    let years = []
    for (let year = start; year <= end; year += this.step) years.push(year)
    if (this.step !== 1 && years.at(-1) !== current) years.push(current)
    const template = this.placeTargets.find(item => item.dataset.placeId === this.selected)
    const states = template ? [...template.content.querySelectorAll(".historical-state")] : []
    if (this.historyMode && states.length) {
      const dates = states.flatMap(item => [item.dataset.from, item.dataset.to]).filter(value => value !== "").map(Number).filter(Number.isFinite)
      years = [...new Set(dates)].sort((a, b) => a - b)
    }
    if (!years.length) years = [selected]
    this.element.querySelector(".period-track").hidden = Boolean(this.selected)
    this.element.querySelector(".style-track").hidden = Boolean(this.selected)
    this.placePeriodsTarget.hidden = !this.selected
    this.placePeriodsTarget.replaceChildren(...states.map(state => {
      const button = document.createElement("button")
      button.type = "button"
      button.textContent = state.querySelector("h3").textContent
      button.title = `${button.textContent}: ${state.dataset.from || "?"} — ${state.dataset.to || "настоящее время"}`
      button.dataset.year = state.dataset.from || state.dataset.to || selected
      button.dataset.action = "memory-map#selectYear"
      return button
    }))
    if (this.selected && !states.length) this.placePeriodsTarget.textContent = "Исторические периоды этого места пока не добавлены."
    const timeline = this.element.querySelector(".timeline")
    const mobile = window.matchMedia("(max-width: 767px)").matches
    const axisColumns = Math.max(mobile ? 5 : 10, years.length)
    timeline.style.setProperty("--axis-columns", axisColumns)
    this.yearsTarget.replaceChildren(...years.map((year, index) => {
      const button = document.createElement("button")
      button.type = "button"
      const label = document.createElement("span")
      label.textContent = year
      const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
      svg.setAttribute("viewBox", "0 0 100 38")
      svg.setAttribute("preserveAspectRatio", "none")
      svg.setAttribute("aria-hidden", "true")
      svg.setAttribute("focusable", "false")
      const shape = document.createElementNS(svg.namespaceURI, "path")
      shape.setAttribute("d", "M2 19L17 5Q20 2 26 2H74Q80 2 83 5L98 19L83 33Q80 36 74 36H26Q20 36 17 33Z")
      svg.append(shape)
      button.append(svg, label)
      button.style.gridColumn = Math.round(index * (axisColumns - 1) / Math.max(1, years.length - 1)) + 1
      button.dataset.year = year
      button.dataset.action = "memory-map#selectYear"
      return button
    }))
    const trackEnds = new Map()
    this.element.querySelectorAll("[data-axis-from]").forEach(item => {
      const overlap = Math.min(Number(item.dataset.axisTo), end) - Math.max(Number(item.dataset.axisFrom), start)
      item.hidden = overlap <= 0
      if (item.hidden) return
      const count = axisColumns
      const length = Math.max(1, end - start)
      const left = Math.max(trackEnds.get(item.parentElement) || 0, Math.min(count - 1, Math.round((Number(item.dataset.axisFrom) - start) / length * count)))
      const right = Math.max(left + 1, Math.min(count, Math.round((Number(item.dataset.axisTo) - start) / length * count)))
      item.style.gridColumn = `${left + 1} / ${right + 1}`
      trackEnds.set(item.parentElement, right)
    })
    this.updateYearButtons()
    if (window.matchMedia("(max-width: 767px)").matches) {
      const selectedButton = this.yearsTarget.querySelector('[aria-pressed="true"]')
      timeline.scrollLeft = selectedButton ? selectedButton.offsetLeft - timeline.clientWidth / 2 : timeline.scrollWidth
    }
  }

  updateYearButtons() {
    this.yearsTarget.querySelectorAll("button").forEach(button => {
      const active = !this.allYearsTarget.checked && Number(button.dataset.year) === Number(this.yearTarget.value)
      button.setAttribute("aria-pressed", String(active))
    })
    this.element.querySelectorAll("[data-step]").forEach(button => button.setAttribute("aria-pressed", String(Number(button.dataset.step) === this.step)))
  }

  selectYear(event) {
    this.yearTarget.value = event.currentTarget.dataset.year
    this.changeYear()
  }

  setStep(event) {
    this.historyMode = false
    this.step = Number(event.currentTarget.dataset.step)
    this.renderYears()
  }

  toggleMenu() {
    const open = !this.element.classList.contains("mobile-menu-open")
    this.element.classList.toggle("mobile-menu-open", open)
    const button = this.element.querySelector(".mobile-menu-toggle")
    button.setAttribute("aria-expanded", String(open))
    button.setAttribute("aria-label", open ? "Закрыть меню" : "Открыть меню")
  }

  closeMenu() {
    this.element.classList.remove("mobile-menu-open")
    const button = this.element.querySelector(".mobile-menu-toggle")
    button?.setAttribute("aria-expanded", "false")
    button?.setAttribute("aria-label", "Открыть меню")
  }

  togglePanel(event) {
    const button = event.currentTarget
    const panel = this.element.querySelector(`#${button.getAttribute("aria-controls")}`)
    panel.hidden = !panel.hidden
    button.setAttribute("aria-expanded", String(!panel.hidden))
    button.querySelector("span").textContent = panel.hidden ? "+" : "−"
  }

  showSources(event) { event.preventDefault(); this.sourcesTarget.showModal() }
  closeSources() { this.sourcesTarget.close() }

  changeYear() {
    this.allYearsTarget.checked = false
    this.filter()
  }

  filter() {
    this.yearLabelTarget.textContent = this.allYearsTarget.checked ? "Выберите год на временной шкале" : `Год: ${this.yearTarget.value}`
    this.updateYearButtons()
    this.placeTargets.forEach(template => {
      const id = template.dataset.placeId
      const checkboxes = [...this.element.querySelectorAll(".category-filter input")]
      const categoryVisible = template.dataset.category === "uncategorized" || !checkboxes.length || checkboxes.some(input => input.checked && input.value === template.dataset.category)
      const visible = categoryVisible && (this.allYearsTarget.checked || this.matches(template.dataset))
      this.element.querySelectorAll(".place-link").forEach(button => {
        if (button.dataset.placeId === id) button.hidden = !visible
      })
      const marker = this.markers?.get(id)
      if (marker && this.map) {
        const added = this.map.geoObjects.indexOf(marker) !== -1
        if (visible && !added) this.map.geoObjects.add(marker)
        if (!visible && added) this.map.geoObjects.remove(marker)
      }
      if (this.selected === id && !visible) this.close()
    })
    this.highlightStates()
  }

  open(event) { this.show(event.currentTarget.dataset.placeId, event.currentTarget) }

  show(id, trigger = null) {
    const template = this.placeTargets.find(item => item.dataset.placeId === id)
    if (!template || (!this.allYearsTarget.checked && !this.matches(template.dataset))) return
    const category = this.element.querySelector(`.category-filter input[value="${template.dataset.category}"]`)
    if (category && !category.checked) return
    if (!this.selected) this.previousTimeline = { year: this.yearTarget.value, all: this.allYearsTarget.checked, step: this.step }
    this.selected = id
    this.historyMode = true
    this.renderYears()
    this.trigger = trigger
    this.bodyTarget.replaceChildren(template.content.cloneNode(true))
    this.articleTarget.hidden = false
    this.element.classList.add("article-open")
    this.scrollTarget.scrollTop = 0
    this.element.querySelectorAll(".place-link").forEach(button => button.setAttribute("aria-expanded", String(button.dataset.placeId === id)))
    this.highlightStates()
    this.closeTarget.focus({ preventScroll: true })
  }

  highlightStates() {
    this.bodyTarget.querySelectorAll(".historical-state").forEach(section => {
      const active = !this.allYearsTarget.checked && this.matches(section.dataset)
      section.classList.toggle("current", active)
      if (active) section.open = true
    })
  }

  close() {
    this.closeMenu()
    if (this.articleTarget.hidden) return
    this.articleTarget.hidden = true
    this.element.classList.remove("article-open")
    this.selected = null
    this.historyMode = false
    if (this.previousTimeline) {
      this.yearTarget.value = this.previousTimeline.year
      this.allYearsTarget.checked = this.previousTimeline.all
      this.step = this.previousTimeline.step
      this.previousTimeline = null
    }
    this.renderYears()
    this.element.querySelectorAll(".place-link").forEach(button => button.setAttribute("aria-expanded", "false"))
    const fallback = [...this.element.querySelectorAll(".place-link")].find(button => !button.hidden)
    const target = this.trigger && !this.trigger.hidden ? this.trigger : fallback
    target?.focus({ preventScroll: true })
    this.filter()
  }

  teardown() {
    this.disposed = true
    window.removeEventListener("resize", this.onViewportChange)
    this.mapResizeObserver?.disconnect()
    this.close()
    if (this.sourcesTarget.open) this.sourcesTarget.close()
    this.map?.destroy()
    this.map = null
    this.markers?.clear()
  }

  disconnect() { this.teardown() }
}
