import { Controller } from "@hotwired/stimulus"

export default class CollapseController extends Controller {
  close(): void {
    this.element.removeAttribute("open")
  }
}
