import { Controller } from "@hotwired/stimulus"

let paddleReady = false

export default class PaddleCheckoutController extends Controller {
  static values = {
    clientToken: String,
    environment: String,
    customerId: String
  }

  connect() {
    if (paddleReady) return
    Paddle.Environment.set(this.environmentValue)
    Paddle.Initialize({
      token: this.clientTokenValue,
      eventCallback: (data) => {
        if (data.name === "checkout.completed") window.location.reload()
      }
    })
    paddleReady = true
  }

  openCheckout({ params }: { params: { priceId: string } }) {
    Paddle.Checkout.open({
      customer: { id: this.customerIdValue },
      items: [{ priceId: params.priceId, quantity: 1 }]
    })
  }
}
