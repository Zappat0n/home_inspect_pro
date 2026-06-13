import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event: Event): void {
    (event.target as HTMLInputElement).form?.requestSubmit()
  }
}
