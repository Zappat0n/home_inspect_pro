import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["navbar", "brandLink"]

  private boundOnScroll!: () => void

  connect() {
    this.boundOnScroll = this.onScroll.bind(this)
    window.addEventListener("scroll", this.boundOnScroll, { passive: true })
    this.applyState()
  }

  disconnect() {
    window.removeEventListener("scroll", this.boundOnScroll)
  }

  private onScroll() {
    this.applyState()
  }

  private applyState() {
    const scrolled = window.scrollY >= 10
    const nav = this.navbarTarget

    nav.classList.toggle("bg-transparent", !scrolled)
    nav.classList.toggle("bg-white", scrolled)
    nav.classList.toggle("shadow-md", scrolled)
    nav.classList.toggle("border-b", scrolled)
    nav.classList.toggle("border-gray-200", scrolled)

    this.brandLinkTargets.forEach((el: HTMLElement) => {
      el.classList.toggle("!text-white", !scrolled)
      el.classList.toggle("!text-gray-900", scrolled)
    })
  }
}
