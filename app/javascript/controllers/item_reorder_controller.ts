import { Controller } from "@hotwired/stimulus"

export default class ItemReorderController extends Controller {
  static values = {
    reorderUrl: String
  }

  declare readonly reorderUrlValue: string

  private draggedItem: HTMLElement | null = null
  private orderedIds: number[] = []
  private initialPositions: number[] = []

  dragstart(event: DragEvent): void {
    const item = (event.target as HTMLElement).closest("[data-item-reorder-id]") as HTMLElement
    if (!item) return

    this.draggedItem = item
    item.classList.add("opacity-50")
    event.dataTransfer!.effectAllowed = "move"

    const container = item.parentElement
    if (!container) return

    const allItems = container.querySelectorAll<HTMLElement>("[data-item-reorder-id]")
    this.orderedIds = Array.from(allItems).map(el =>
      Number(el.dataset.itemReorderId)
    )
    this.initialPositions = Array.from(allItems).map(el =>
      Number(el.dataset.itemReorderPosition)
    )
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

    const draggedId = Number(this.draggedItem.dataset.itemReorderId)
    const targetId = Number(target.dataset.itemReorderId)
    const fromIndex = this.orderedIds.indexOf(draggedId)
    let toIndex = this.orderedIds.indexOf(targetId)

    if (fromIndex !== -1 && toIndex !== -1) {
      this.orderedIds.splice(fromIndex, 1)
      if (after) toIndex += 1
      if (fromIndex < toIndex) toIndex -= 1
      this.orderedIds.splice(toIndex, 0, draggedId)
    }
  }

  drop(event: DragEvent): void {
    event.preventDefault()
    if (!this.draggedItem) return

    const positions = this.orderedIds.map((id, index) => ({
      id: id,
      position: this.initialPositions[index]
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
        const scrollX = window.scrollX
        const scrollY = window.scrollY
        window.Turbo.renderStreamMessage(html)
        window.scrollTo(scrollX, scrollY)
      })
      .catch(() => {
        window.location.reload()
      })
  }

  dragend(): void {
    this.draggedItem?.classList.remove("opacity-50")
    this.draggedItem = null
    this.orderedIds = []
  }

  private getCsrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return (meta as HTMLMetaElement)?.content || ""
  }
}
