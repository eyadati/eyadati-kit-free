'use strict';


const CACHE_NAME = 'app-shell-v1';

const PRECACHE_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/main.dart.js',
  '/flutter_bootstrap.js'
];

// Install: Cache critical static assets
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      // Best effort caching; don't fail install if a non-critical file is missing
      return Promise.allSettled(
        PRECACHE_ASSETS.map((asset) => cache.add(asset))
      );
    })
  );
});

// Activate: Delete OLD caches immediately and claim clients
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
      );
    }).then(() => self.clients.claim())
  );
});

// Update is applied only when the user confirms (see index.html applyAppUpdate)
self.addEventListener('message', (event) => {
  if (event.data && event.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  if (event.data === 'NOTIFICATIONS_VISIBLE') {
    self.registration.getNotifications().then((notifications) => {
      notifications.forEach((n) => n.close());
    });
  }
});

// Fetch Interceptor: Smart Caching Strategy
self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // RULE 1: NEVER intercept or cache Supabase requests, auth endpoints, or websockets
  if (
    url.origin.includes('supabase.co') ||
    url.pathname.startsWith('/rest/') ||
    url.pathname.startsWith('/auth/') ||
    url.pathname.startsWith('/realtime/')
  ) {
    return;
  }

  // RULE 2: Never cache version.json or index.html in the SW cache layer
  if (url.pathname === '/version.json' || url.pathname === '/index.html') {
    return;
  }

  // RULE 3: For GET requests to local static assets, use Stale-While-Revalidate
  if (event.request.method === 'GET') {
    event.respondWith(
      caches.open(CACHE_NAME).then(async (cache) => {
        const cachedResponse = await cache.match(event.request);

        const fetchPromise = fetch(event.request).then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            cache.put(event.request, networkResponse.clone());
          }
          return networkResponse;
        }).catch(() => cachedResponse || (event.request.mode === 'navigate'
          ? caches.match('/index.html')
          : undefined));

        return cachedResponse || fetchPromise;
      })
    );
  }
});

// Handle notification click: focus or open the app
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const urlToOpen = '/';
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((windowClients) => {
      const focused = windowClients.find((c) => c.focused);
      if (focused) {
        focused.focus();
        return;
      }
      const existing = windowClients.find((c) => c.visibilityState === 'visible');
      if (existing) {
        existing.focus();
        return;
      }
      clients.openWindow(urlToOpen);
    })
  );
});
