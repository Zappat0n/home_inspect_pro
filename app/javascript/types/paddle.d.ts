declare var Paddle: {
  Environment: {
    set: (env: string) => void
  }
  Initialize: (config: { token: string; eventCallback?: (data: { name: string }) => void }) => void
  Checkout: {
    open: (config: { customer: { id: string }; items: Array<{ priceId: string; quantity: number }> }) => void
  }
}
