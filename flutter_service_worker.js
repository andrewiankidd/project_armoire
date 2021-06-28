'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "icons/Icon-512.png": "a675e8bbb07b281855168929295527ff",
"icons/Icon-192.png": "163f981aa3752edc5af1178e5ca89ae7",
"version.json": "23808f84b01748770572f725ba308f28",
"manifest.json": "17204efbe249f13c3e062c9dac1bd3a2",
"assets/AssetManifest.json": "d0b5f1c9c8ee09d31d188bcdb3147854",
"assets/assets/images/wound.png": "2004ff983abee45b25f5174c64da4ce6",
"assets/assets/images/buttons/background.png": "8c9aa78348b48e03f06bb97f74b819c9",
"assets/assets/images/buttons/atack_range.png": "8994f23fc67442c8361432f0cc9a2fa1",
"assets/assets/images/uncloaked.png": "e512aeabf4214125e4bd30cee2c8b023",
"assets/assets/images/maps/biome2/tileset.json": "2b5fa918227fe6b58df9c57827ae0c40",
"assets/assets/images/maps/biome2/data.json": "8b583d3f740d10b6051a67d06167f76c",
"assets/assets/images/maps/biome2/tileset.png": "491e506fbfa06177ad91771b74f86d01",
"assets/assets/images/maps/biome1/tilese+t.png": "ec2cc3e413fecc22cedad090324fb1b9",
"assets/assets/images/maps/biome1/tileset.json": "c781d94371d50cf7c26bd8d83d47229f",
"assets/assets/images/maps/biome1/fullblockfollision.tx": "aa1c5236ac89f3987698cd253a3bfec6",
"assets/assets/images/maps/biome1/data.json": "f62c000d2f09edc49cad79fd80d7f2ba",
"assets/assets/images/maps/biome1/tileset.png": "442a346283058f2086a5e5d1b56d1eeb",
"assets/assets/images/nowound.png": "e512aeabf4214125e4bd30cee2c8b023",
"assets/assets/images/cloaked.png": "ce0a553a76e8cefe27c616e6bbcc8906",
"assets/assets/images/hero1.png": "08730d084495a7ccc2c7c283c3822d25",
"assets/NOTICES": "aedc8d723218fa7351d42e7efdd6900a",
"assets/FontManifest.json": "d751713988987e9331980363e24189ce",
"game/index.html": "b8bc01487b5fa4c770b1ef6d8c5b83ac",
"/": "2910f35308707a8fcd7db2ec3115c827",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "db6cdf3d2914efc7655a9a3d9afb2101",
"index.html": "2910f35308707a8fcd7db2ec3115c827"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
