import { Controller } from "@hotwired/stimulus"
import { storeFile, getFile, deleteFile } from "../lib/offline_storage"

interface QueuedRequest {
  url: string
  method: string
  body: Record<string, string>
  timestamp: number
  fileId?: string
  fileName?: string
  fileType?: string
}

export default class OfflineQueueController extends Controller {
  static targets = ["count", "pending"]
  static values = { queued: Number }

  declare readonly hasCountTarget: boolean
  declare readonly countTarget: HTMLElement
  declare readonly hasPendingTarget: boolean
  declare readonly pendingTarget: HTMLElement
  declare queuedValue: number

  private storageKey = "offline-form-queue"

  connect(): void {
    this.queuedValue = this.getQueue().length
    this.updateCount()

    document.addEventListener("turbo:submit-start", this.handleSubmitStart)
    window.addEventListener(
      "offline:status-change",
      this.handleStatusChange as EventListener,
    )
  }

  disconnect(): void {
    document.removeEventListener("turbo:submit-start", this.handleSubmitStart)
    window.removeEventListener(
      "offline:status-change",
      this.handleStatusChange as EventListener,
    )
  }

  private handleSubmitStart = (event: Event): void => {
    if (navigator.onLine) return

    const turboEvent = event as any
    const formSubmission = turboEvent.detail?.formSubmission
    if (!formSubmission) return

    const form = formSubmission.formElement as HTMLFormElement
    if (!form) return

    event.preventDefault()
    event.stopImmediatePropagation()

    const body: Record<string, string> = {}
    const formData = new FormData(form)
    let fileId: string | undefined
    let fileName: string | undefined
    let fileType: string | undefined

    formData.forEach((value, key) => {
      if (value instanceof File) {
        fileId = String(Date.now()) + "-" + Math.random().toString(36).slice(2)
        fileName = value.name
        fileType = value.type
        storeFile(fileId, value)
      } else {
        body[key] = value as string
      }
    })

    this.enqueue({
      url: form.action,
      method: form.method.toUpperCase() || "POST",
      body,
      timestamp: Date.now(),
      fileId,
      fileName,
      fileType,
    })
  }

  private handleStatusChange = (event: Event): void => {
    const detail = (event as CustomEvent).detail
    if (detail.online) {
      this.replayQueue()
    }
  }

  private enqueue(request: QueuedRequest): void {
    const queue = this.getQueue()
    queue.push(request)
    localStorage.setItem(this.storageKey, JSON.stringify(queue))
    this.queuedValue = queue.length
    this.updateCount()
  }

  private async replayQueue(): Promise<void> {
    const queue = this.getQueue()
    if (queue.length === 0) return

    const remaining: QueuedRequest[] = []

    for (const item of queue) {
      try {
        let response: Response

        if (item.fileId) {
          const file = await getFile(item.fileId)
          if (!file) {
            remaining.push(item)
            continue
          }

          const body = new FormData()
          Object.entries(item.body).forEach(([key, value]) => {
            body.append(key, value)
          })
          body.append("photo", file, item.fileName || "photo.jpg")

          response = await fetch(item.url, {
            method: item.method,
            headers: {
              "Accept": "text/vnd.turbo-stream.html, text/html",
              "X-CSRF-Token": this.getCsrfToken(),
            },
            body,
          })

          if (response.ok) {
            deleteFile(item.fileId)
          }
        } else {
          const body = new URLSearchParams()
          Object.entries(item.body).forEach(([key, value]) => {
            body.append(key, value)
          })

          response = await fetch(item.url, {
            method: item.method,
            headers: {
              "Accept": "text/vnd.turbo-stream.html, text/html",
              "Content-Type": "application/x-www-form-urlencoded",
              "X-CSRF-Token": this.getCsrfToken(),
            },
            body,
          })
        }

        if (response.ok) {
          const html = await response.text()
          const Turbo = (window as any).Turbo
          if (Turbo && html.includes("turbo-stream")) {
            Turbo.renderStreamMessage(html)
          }
        } else {
          remaining.push(item)
        }
      } catch {
        remaining.push(item)
      }
    }

    localStorage.setItem(this.storageKey, JSON.stringify(remaining))
    this.queuedValue = remaining.length
    this.updateCount()
  }

  private getQueue(): QueuedRequest[] {
    try {
      const data = localStorage.getItem(this.storageKey)
      return data ? JSON.parse(data) : []
    } catch {
      return []
    }
  }

  private getCsrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    if (!meta) return ""

    return (meta as HTMLMetaElement).content
  }

  private updateCount(): void {
    if (this.hasCountTarget) {
      this.countTarget.textContent = String(this.queuedValue)
      if (this.queuedValue > 0) {
        this.countTarget.classList.remove("hidden")
      } else {
        this.countTarget.classList.add("hidden")
      }
    }

    const photoCount = this.getQueue().filter(item => item.fileId).length
    if (this.hasPendingTarget && photoCount > 0) {
      this.pendingTarget.textContent = String(photoCount)
      this.pendingTarget.classList.remove("hidden")
    } else if (this.hasPendingTarget) {
      this.pendingTarget.classList.add("hidden")
    }
  }
}
