import { Controller } from "@hotwired/stimulus"

export default class InspectionItemController extends Controller {
  static targets = ["commentContainer", "statusRadio"]
  static values = {
    defectValue: { type: String, default: "defect" }
  }

  connect() {
    this.toggleCommentVisibility()
  }

  statusChanged() {
    console.log("clicked");
    this.toggleCommentVisibility()
  }

  toggleCommentVisibility() {
    if (!this.hasStatusRadioTarget || !this.hasCommentContainerTarget) return
    debugger

    const selectedRadio = this.statusRadioTargets.find(radio => radio.checked)

    if (selectedRadio && selectedRadio.value === this.defectValue) {
      this.commentContainerTarget.classList.remove("hidden")
    } else {
      this.commentContainerTarget.classList.add("hidden")
    }
  }
}
