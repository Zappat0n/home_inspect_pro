import { Controller } from "@hotwired/stimulus"

export default class OfflineIndicatorController extends Controller {
  static targets = ["banner"]
  static values = { online: Boolean }

  declare readonly bannerTarget: HTMLElement
  declare onlineValue: boolean

  connect(): void {
    this.onlineValue = navigator.onLine
    this.updateBanner()

    window.addEventListener("online", this.handleOnline)
    window.addEventListener("offline", this.handleOffline)
  }

  disconnect(): void {
    window.removeEventListener("online", this.handleOnline)
    window.removeEventListener("offline", this.handleOffline)
  }

  dismiss(): void {
    this.bannerTarget.classList.add("hidden")
  }

  private handleOnline = (): void => {
    this.onlineValue = true
    this.updateBanner()
    window.dispatchEvent(
      new CustomEvent("offline:status-change", { detail: { online: true } }),
    )
  }

  private handleOffline = (): void => {
    this.onlineValue = false
    this.updateBanner()
    window.dispatchEvent(
      new CustomEvent("offline:status-change", { detail: { online: false } }),
    )
  }

  private updateBanner(): void {
    if (this.onlineValue) {
      this.bannerTarget.classList.add("hidden")
    } else {
      this.bannerTarget.classList.remove("hidden")
    }
  }
}
