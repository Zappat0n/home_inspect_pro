import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

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

  clear(): void {
    this.send("clear", {})
  }

  handleCapture(message: { data: { image?: string } }): void {
    const imageData = message.data?.image
    if (!imageData) return

    this.signatureInputTarget.value = imageData

    const img = new Image()
    img.onload = () => {
      const ctx = this.canvasTarget.getContext("2d")
      if (ctx) {
        ctx.drawImage(img, 0, 0)
      }
    }
    img.src = imageData
  }
}
