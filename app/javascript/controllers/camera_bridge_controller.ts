import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class CameraBridgeController extends BridgeComponent {
  static component = "camera"
  static targets = ["nativeButton", "webLabel", "webInput"]
  static values = { actionUrl: String }

  declare readonly nativeButtonTarget: HTMLElement
  declare readonly webLabelTarget: HTMLElement
  declare readonly webInputTarget: HTMLElement
  declare readonly actionUrlValue: string

  connect(): void {
    super.connect()

    this.nativeButtonTarget.style.display = "none"
    this.webLabelTarget.style.display = ""

    if (this.enabled) {
      this.webLabelTarget.style.display = "none"
      this.nativeButtonTarget.style.display = ""
    }
  }

  capture(): void {
    this.send("capture", {}, this.handleCapture.bind(this))
  }

  handleCapture(message: { data: { image?: string } }): void {
    const imageData = message.data?.image
    if (!imageData) return

    const blob = this.dataURItoBlob(imageData)
    const file = new File([blob], "photo.jpg", { type: "image/jpeg" })

    const formData = new FormData()
    formData.append("inspection_photo[photo]", file)

    fetch(this.actionUrlValue, {
      method: "POST",
      body: formData,
      headers: { "Accept": "text/vnd.turbo-stream.html, text/html, application/json" },
      credentials: "same-origin",
    })
      .then((response) => {
        if (response.ok) {
          response.text().then((html) => {
            if (window.Turbo?.renderStreamMessage) {
              window.Turbo.renderStreamMessage(html)
            }
          })
        }
      })
  }

  private dataURItoBlob(dataURI: string): Blob {
    const byteString = atob(dataURI.split(",")[1])
    const mimeString = dataURI.split(",")[0].split(":")[1].split(";")[0]
    const ab = new ArrayBuffer(byteString.length)
    const ia = new Uint8Array(ab)

    for (let i = 0; i < byteString.length; i++) {
      ia[i] = byteString.charCodeAt(i)
    }

    return new Blob([ab], { type: mimeString })
  }
}
