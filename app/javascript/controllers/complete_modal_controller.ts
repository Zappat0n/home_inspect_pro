import { Controller } from "@hotwired/stimulus"

export default class CompleteModalController extends Controller {
  static targets = ["container", "submitButton"]

  declare readonly containerTarget: HTMLElement
  declare readonly submitButtonTarget?: HTMLButtonElement

  open(): void {
    this.containerTarget.classList.remove("hidden")
    document.body.style.overflow = "hidden"
    this.disableSubmit()
  }

  close(): void {
    this.containerTarget.classList.add("hidden")
    document.body.style.overflow = ""
  }

  backdropClose(event: MouseEvent): void {
    if (event.target === this.containerTarget) {
      this.close()
    }
  }

  enableSubmit(): void {
    const btn = this.targets.find("submitButton") as HTMLButtonElement | null
    if (btn) btn.disabled = false
  }

  disableSubmit(): void {
    const btn = this.targets.find("submitButton") as HTMLButtonElement | null
    if (btn) btn.disabled = true
  }
}
