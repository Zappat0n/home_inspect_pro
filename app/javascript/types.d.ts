// Augment the global Window interface for Stimulus
interface Window {
  Stimulus: import("@hotwired/stimulus").Application
}
