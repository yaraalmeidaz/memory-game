// Service Worker to add Cross-Origin Isolation headers
// Required for SharedArrayBuffer and threading in Godot Web

self.addEventListener('install', (event) => {
	self.skipWaiting();
});

self.addEventListener('activate', (event) => {
	event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
	const request = event.request;
	
	// For same-origin requests, add the necessary headers
	if (request.url.startsWith(self.location.origin)) {
		event.respondWith(
			fetch(request).then((response) => {
				// Clone the response to be able to modify the headers
				const clonedResponse = response.clone();
				const newHeaders = new Headers(clonedResponse.headers);
				newHeaders.set('Cross-Origin-Embedder-Policy', 'require-corp');
				newHeaders.set('Cross-Origin-Opener-Policy', 'same-origin');
				
				return new Response(clonedResponse.body, {
					status: clonedResponse.status,
					statusText: clonedResponse.statusText,
					headers: newHeaders
				});
			}).catch((error) => {
				console.error('Service Worker fetch error:', error);
				return fetch(request);
			})
		);
	} else {
		// For cross-origin requests, just do normal fetch
		event.respondWith(fetch(request));
	}
});
