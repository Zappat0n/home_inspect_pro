import { BridgeComponent } from "@hotwired/hotwire-native-bridge"
import CompleteModalController from "./complete_modal_controller"

export default class SignatureBridgeController extends BridgeComponent {
  static component = "signature"
  static targets = ["webCanvas", "nativeButton", "canvas", "signatureInput"]

  declare readonly webCanvasTarget: HTMLElement
  declare readonly nativeButtonTarget: HTMLElement
  declare readonly canvasTarget: HTMLCanvasElement
  declare readonly signatureInputTarget: HTMLInputElement

  connect(): void {
    super.connect()

    this.webCanvasTarget.style.display = ""
    this.nativeButtonTarget.style.display = "none"

    if (this.enabled) {
      this.webCanvasTarget.style.display = "none"
      this.nativeButtonTarget.style.display = ""
    }
  }

  capture(): void {
    this.send("capture", {}, this.handleCapture.bind(this))
  }

  captureForSubmit(): void {
    if (!this.enabled) {
      const dataUrl = this.canvasTarget.toDataURL("image/png")
      this.signatureInputTarget.value = dataUrl
    }
  }

  clear(): void {
    this.send("clear", {})
    if (this.enabled) {
      this.signatureInputTarget.value = ""
      const ctx = this.canvasTarget.getContext("2d")
      if (ctx) {
        ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
      }
      this.webCanvasTarget.style.display = "none"
      this.nativeButtonTarget.style.display = ""
    }
  }

  handleCapture(message: { data: { image?: string } }): void {
    const imageData = message.data?.image
    if (!imageData) return

    this.webCanvasTarget.style.display = ""
    this.nativeButtonTarget.style.display = "none"

    this.canvasTarget.width = this.canvasTarget.offsetWidth
    this.canvasTarget.height = this.canvasTarget.offsetHeight

    const dataUrl = imageData.startsWith("data:") ? imageData : `data:image/png;base64,${imageData}`
    this.signatureInputTarget.value = dataUrl

    this.notifyModal()

    const img = new Image()
    img.onload = () => {
      const ctx = this.canvasTarget.getContext("2d")
      if (ctx) {
        ctx.drawImage(img, 0, 0, this.canvasTarget.width, this.canvasTarget.height)
      }
    }
    img.src = dataUrl
  }

  private notifyModal(): void {
    const modal = this.application.getControllerForElementAndIdentifier(
      this.element.closest("[data-controller~='complete-modal']") || this.element,
      "complete-modal"
    ) as CompleteModalController | null

    if (this.signatureInputTarget.value.length > 0) {
      modal?.enableSubmit()
    } else {
      modal?.disableSubmit()
    }
  }
}
