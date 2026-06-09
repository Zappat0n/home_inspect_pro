// Augment the global Window interface for Stimulus and Turbo
interface Window {
  Stimulus: import("@hotwired/stimulus").Application
  Turbo: {
    renderStreamMessage(html: string): void
  }
}

declare module "@hotwired/hotwire-native-bridge" {
  import { Controller } from "@hotwired/stimulus"

  export class BridgeComponent extends Controller {
    static component: string
    static get shouldLoad(): boolean
    get enabled(): boolean
    send(event: string, data?: Record<string, unknown>, callback?: (message: any) => void): void
  }
}
