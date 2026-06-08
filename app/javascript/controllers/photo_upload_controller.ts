import { Controller } from "@hotwired/stimulus"

export default class PhotoUploadController extends Controller {
  upload(event: Event): void {
    const input = event.target as HTMLInputElement

    if (input.files?.length) {
      const form = this.element.closest("form")

      if (form) {
        form.requestSubmit()
      }
    }
  }
}
