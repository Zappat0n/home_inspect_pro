import { Controller } from "@hotwired/stimulus"
import CompleteModalController from "./complete_modal_controller"

export default class SignaturePadController extends Controller {
  static targets = ["canvas", "signatureInput", "clearButton"]
  static values = {
    lineWidth: { type: Number, default: 2 },
    lineColor: { type: String, default: "#1a1a1a" }
  }

  private drawing = false
  private canvasContext: CanvasRenderingContext2D | null = null
  private observer: IntersectionObserver | null = null
  private boundStartDrawing!: (event: MouseEvent | TouchEvent) => void
  private boundDraw!: (event: MouseEvent | TouchEvent) => void
  private boundStopDrawing!: (event: Event) => void

  connect() {
    this.setupCanvas()

    this.boundStartDrawing = this.startDrawing.bind(this)
    this.boundDraw = this.draw.bind(this)
    this.boundStopDrawing = this.stopDrawing.bind(this)

    const canvas = this.canvasTarget
    canvas.addEventListener("mousedown", this.boundStartDrawing)
    canvas.addEventListener("mousemove", this.boundDraw)
    canvas.addEventListener("mouseup", this.boundStopDrawing)
    canvas.addEventListener("mouseleave", this.boundStopDrawing)
    canvas.addEventListener("touchstart", this.boundStartDrawing, { passive: true })
    canvas.addEventListener("touchmove", this.boundDraw, { passive: false })
    canvas.addEventListener("touchend", this.boundStopDrawing)

    this.observer = new IntersectionObserver((entries) => {
      if (entries[0].isIntersecting) {
        this.setupCanvas()
      }
    })
    this.observer.observe(canvas)
  }

  disconnect() {
    const canvas = this.canvasTarget
    canvas.removeEventListener("mousedown", this.boundStartDrawing)
    canvas.removeEventListener("mousemove", this.boundDraw)
    canvas.removeEventListener("mouseup", this.boundStopDrawing)
    canvas.removeEventListener("mouseleave", this.boundStopDrawing)
    canvas.removeEventListener("touchstart", this.boundStartDrawing)
    canvas.removeEventListener("touchmove", this.boundDraw)
    canvas.removeEventListener("touchend", this.boundStopDrawing)
    this.observer?.disconnect()
  }

  setupCanvas() {
    const canvas = this.canvasTarget
    if (canvas.offsetWidth === 0) return

    canvas.width = canvas.offsetWidth
    canvas.height = canvas.offsetHeight

    this.canvasContext = canvas.getContext("2d")
    if (!this.canvasContext) return

    this.canvasContext.lineCap = "round"
    this.canvasContext.lineJoin = "round"
    this.canvasContext.lineWidth = this.lineWidthValue
    this.canvasContext.strokeStyle = this.lineColorValue
  }

  startDrawing(event: MouseEvent | TouchEvent) {
    const position = this.getPosition(event)
    if (!position) return

    const ctx = this.canvasContext
    if (!ctx) return

    ctx.beginPath()
    ctx.moveTo(position.x, position.y)
    this.drawing = true
  }

  draw(event: MouseEvent | TouchEvent) {
    if (!this.drawing) return

    event.preventDefault()

    const position = this.getPosition(event)
    if (!position) return

    const ctx = this.canvasContext
    if (!ctx) return

    ctx.lineTo(position.x, position.y)
    ctx.stroke()
  }

  stopDrawing() {
    this.drawing = false
    this.capture()
    this.notifyModal()
  }

  clear() {
    const canvas = this.canvasTarget
    const ctx = this.canvasContext

    if (ctx) {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
    }

    this.signatureInputTarget.value = ""
    this.notifyModal()
  }

  capture() {
    const dataUrl = this.canvasTarget.toDataURL("image/png")
    this.signatureInputTarget.value = dataUrl
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

  private getPosition(event: MouseEvent | TouchEvent): { x: number; y: number } | null {
    const canvas = this.canvasTarget
    const rect = canvas.getBoundingClientRect()

    if ("touches" in event) {
      const touch = event.touches[0]
      if (!touch) return null

      return {
        x: touch.clientX - rect.left,
        y: touch.clientY - rect.top
      }
    }

    return {
      x: event.clientX - rect.left,
      y: event.clientY - rect.top
    }
  }
}
