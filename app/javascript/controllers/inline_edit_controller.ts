import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  declare readonly formTarget: HTMLElement
  declare readonly hasFormTarget: boolean

  toggle(): void {
    this.formTarget.classList.toggle("hidden")
  }
}
