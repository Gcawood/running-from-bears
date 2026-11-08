// Offline support for the home-screen web app. Network first, so a deploy
// reaches players the next time they're online; the cache is the fallback.
const CACHE = 'rfb-v1';
const FILES = [
  './', 'index.html', 'manifest.webmanifest',
  'running_from_bears.html', 'running_from_bears_wireframe.html',
  'rfbflat.js', 'rfbflat.wasm', 'rfb3d.js', 'rfb3d.wasm',
  'apple-touch-icon.png', 'icon-192.png', 'icon-512.png'
];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(FILES)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(caches.keys()
    .then((keys) => Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k))))
    .then(() => self.clients.claim()));
});

self.addEventListener('fetch', (e) => {
  if (e.request.method !== 'GET') return;
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put(e.request, copy));
        return res;
      })
      .catch(() => caches.match(e.request, { ignoreSearch: true }))
  );
});
