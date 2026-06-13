import { Controller } from "@hotwired/stimulus"

export default class CategoryReorderController extends Controller {
  static values = {
    reorderUrl: String,
  }

  declare readonly reorderUrlValue: string

  private draggedElement: HTMLElement | null = null

  dragstart(event: DragEvent): void {
    const header = (event.target as HTMLElement).closest("[data-category-handle]") as HTMLElement | null
    if (!header) return

    const section = header.closest("[data-category-id]") as HTMLElement
    if (!section) return

    this.draggedElement = section
    section.classList.add("opacity-50")
    event.dataTransfer!.effectAllowed = "move"
    event.dataTransfer!.setData("text/plain", "")
  }

  dragover(event: DragEvent): void {
    if (!this.draggedElement) return
    event.preventDefault()

    const target = (event.target as HTMLElement).closest("[data-category-id]") as HTMLElement | null
    if (!target || target === this.draggedElement) return

    event.dataTransfer!.dropEffect = "move"

    const rect = target.getBoundingClientRect()
    const after = event.clientY > rect.top + rect.height / 2

    if (after) {
      target.parentElement!.insertBefore(this.draggedElement, target.nextElementSibling)
    } else {
      target.parentElement!.insertBefore(this.draggedElement, target)
    }
  }

  drop(event: DragEvent): void {
    event.preventDefault()
    if (!this.draggedElement) return

    const categoryElements = this.element.querySelectorAll<HTMLElement>("[data-category-id]")
    const positions = Array.from(categoryElements).map((el, i) => ({
      id: Number(el.dataset.categoryId),
      position: i,
    }))

    fetch(this.reorderUrlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "text/vnd.turbo-stream.html",
        "X-CSRF-Token": this.getCsrfToken(),
      },
      body: JSON.stringify({ categories: positions }),
    })
      .then((response) => {
        if (!response.ok) throw new Error("Reorder failed")
        return response.text()
      })
      .then((html) => {
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
    this.draggedElement?.classList.remove("opacity-50")
    this.draggedElement = null
  }

  private getCsrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return (meta as HTMLMetaElement)?.content || ""
  }
}
