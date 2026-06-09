import { Controller } from "@hotwired/stimulus"

export default class InspectionItemController extends Controller {
  static targets = ["commentContainer", "commentForm", "statusRadio"]
  static values = {
    defectValue: { type: String, default: "defect" }
  }

  connect() {
    this.toggleCommentVisibility()
  }

  statusChanged() {
    this.toggleCommentVisibility()
  }

  saveComment() {
    if (this.hasCommentFormTarget && this.commentFormTarget.isConnected) {
      this.commentFormTarget.requestSubmit()
    }
  }

  toggleCommentVisibility() {
    if (!this.hasStatusRadioTarget || !this.hasCommentContainerTarget) return

    const selectedRadio = this.statusRadioTargets.find(radio => radio.checked)

    if (selectedRadio && selectedRadio.value === this.defectValue) {
      this.commentContainerTarget.classList.remove("hidden")
    } else {
      this.commentContainerTarget.classList.add("hidden")
    }
  }
}
