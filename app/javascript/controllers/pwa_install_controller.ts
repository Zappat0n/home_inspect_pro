import { Controller } from "@hotwired/stimulus"

export default class PwaInstallController extends Controller {
  static targets = ["banner"]
  static values = { installed: Boolean }

  declare readonly bannerTarget: HTMLElement
  declare installedValue: boolean

  private deferredPrompt: Event | null = null

  connect(): void {
    this.installedValue = this.isAppInstalled()

    if (this.installedValue) return

    window.addEventListener("beforeinstallprompt", this.handleBeforeInstallPrompt.bind(this))
    window.addEventListener("appinstalled", this.handleAppInstalled.bind(this))
  }

  disconnect(): void {
    window.removeEventListener("beforeinstallprompt", this.handleBeforeInstallPrompt.bind(this))
    window.removeEventListener("appinstalled", this.handleAppInstalled.bind(this))
  }

  handleBeforeInstallPrompt(event: Event): void {
    event.preventDefault()
    this.deferredPrompt = event
    this.bannerTarget.classList.remove("hidden")
  }

  handleAppInstalled(): void {
    this.installedValue = true
    this.bannerTarget.classList.add("hidden")
    this.deferredPrompt = null
    console.log("PWA was installed")
  }

  async install(): Promise<void> {
    if (!this.deferredPrompt) return

    const promptEvent = this.deferredPrompt as any
    promptEvent.prompt()

    const result = await promptEvent.userChoice
    if (result.outcome === "accepted") {
      console.log("User accepted the install prompt")
    } else {
      console.log("User dismissed the install prompt")
    }

    this.deferredPrompt = null
  }

  dismiss(): void {
    this.bannerTarget.classList.add("hidden")
  }

  private isAppInstalled(): boolean {
    return (
      window.matchMedia("(display-mode: standalone)").matches ||
      navigator.userAgent.includes("Hotwire Native") ||
      (window as any).TurboNativeBridge !== undefined
    )
  }
}
