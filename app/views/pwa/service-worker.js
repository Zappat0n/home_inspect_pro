var CACHE_VERSION = "v1"
var STATIC_CACHE = "home-inspect-pro-static-" + CACHE_VERSION
var DYNAMIC_CACHE = "home-inspect-pro-dynamic-" + CACHE_VERSION

var PRECACHE_ASSETS = [
  "/offline",
]

self.addEventListener("install", function(event) {
  event.waitUntil(
    caches.open(STATIC_CACHE).then(function(cache) {
      return cache.addAll(PRECACHE_ASSETS)
    }).catch(function(err) {
      console.error("SW precache failed:", err)
    })
  )
  self.skipWaiting()
})

self.addEventListener("activate", function(event) {
  event.waitUntil(
    caches.keys().then(function(keys) {
      return Promise.all(
        keys
          .filter(function(key) {
            return key !== STATIC_CACHE && key !== DYNAMIC_CACHE
          })
          .map(function(key) {
            return caches.delete(key)
          })
      )
    })
  )
  self.clients.claim()
})

self.addEventListener("fetch", function(event) {
  var request = event.request
  var url = new URL(request.url)

  if (request.method !== "GET") return
  if (url.origin !== self.location.origin) return

  if (url.pathname.startsWith("/admin")) return
  if (url.pathname.startsWith("/up")) return
  if (url.pathname.startsWith("/packs")) return

  if (request.mode === "navigate") {
    event.respondWith(
      fetch(request)
        .then(function(response) {
          if (response.ok) {
            var clone = response.clone()
            caches.open(DYNAMIC_CACHE).then(function(cache) {
              cache.put(request, clone)
            })
          }
          return response
        })
        .catch(function() {
          return caches.match(request).then(function(cached) {
            return cached || caches.match("/offline")
          })
        })
    )
    return
  }

  if (
    request.destination === "script" ||
    request.destination === "style" ||
    request.destination === "font" ||
    request.destination === "image"
  ) {
    event.respondWith(
      caches.match(request).then(function(cachedResponse) {
        if (cachedResponse) return cachedResponse

        return fetch(request).then(function(networkResponse) {
          if (networkResponse.ok) {
            var clone = networkResponse.clone()
            caches.open(STATIC_CACHE).then(function(cache) {
              cache.put(request, clone)
            })
          }
          return networkResponse
        })
      })
    )
    return
  }
})
