export function registerServiceWorker(): void {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker
      .register("/service-worker")
      .then((registration: ServiceWorkerRegistration) => {
        console.log("Service Worker registered:", registration.scope)

        registration.addEventListener("updatefound", () => {
          const installingWorker = registration.installing
          if (installingWorker) {
            installingWorker.addEventListener("statechange", () => {
              if (
                installingWorker.state === "installed" &&
                navigator.serviceWorker.controller
              ) {
                console.log("New service worker available. Reload to update.")
              }
            })
          }
        })
      })
      .catch((error: Error) => {
        console.error("Service Worker registration failed:", error)
      })
  }
}
