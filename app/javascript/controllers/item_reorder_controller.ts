import { Controller } from "@hotwired/stimulus"

export default class ItemReorderController extends Controller {
  static targets = ["item"]
  static values = {
    reorderUrl: String
  }

  declare readonly itemTargets: HTMLElement[]
  declare readonly reorderUrlValue: string

  private draggedItem: HTMLElement | null = null

  dragstart(event: DragEvent): void {
    const item = (event.target as HTMLElement).closest("[data-item-reorder-id]") as HTMLElement
    if (!item) return

    this.draggedItem = item
    item.classList.add("opacity-50")
    event.dataTransfer!.effectAllowed = "move"
  }

  dragover(event: DragEvent): void {
    event.preventDefault()

    const target = (event.target as HTMLElement).closest("[data-item-reorder-id]") as HTMLElement
    if (!target || !this.draggedItem || target === this.draggedItem) return
    if (target.parentElement !== this.draggedItem.parentElement) return

    event.dataTransfer!.dropEffect = "move"

    const rect = target.getBoundingClientRect()
    const after = event.clientY > rect.top + rect.height / 2

    if (after) {
      target.parentElement!.insertBefore(this.draggedItem, target.nextElementSibling)
    } else {
      target.parentElement!.insertBefore(this.draggedItem, target)
    }
  }

  drop(event: DragEvent): void {
    event.preventDefault()
    if (!this.draggedItem) return

    const container = this.draggedItem.parentElement
    if (!container) return

    const items = container.querySelectorAll<HTMLElement>("[data-item-reorder-id]")
    const positions = Array.from(items).map((el, index) => ({
      id: Number(el.dataset.itemReorderId),
      position: index + 1
    }))

    fetch(this.reorderUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": this.getCsrfToken()
      },
      body: JSON.stringify({ items: positions })
    })
      .then(response => {
        if (!response.ok) throw new Error()
        return response.text()
      })
      .then(html => {
        window.Turbo.renderStreamMessage(html)
      })
      .catch(() => {
        window.location.reload()
      })
  }

  dragend(): void {
    this.draggedItem?.classList.remove("opacity-50")
    this.draggedItem = null
  }

  private getCsrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return (meta as HTMLMetaElement)?.content || ""
  }
}
