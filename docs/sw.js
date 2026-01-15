// Service Worker para adicionar headers de Cross-Origin Isolation
// Necessário para SharedArrayBuffer e threading no Godot Web

self.addEventListener('install', (event) => {
	self.skipWaiting();
});

self.addEventListener('activate', (event) => {
	event.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', (event) => {
	const request = event.request;
	
	// Para requisições same-origin, adiciona os headers necessários
	if (request.url.startsWith(self.location.origin)) {
		event.respondWith(
			fetch(request).then((response) => {
				// Clone a resposta para poder modificar os headers
				const newHeaders = new Headers(response.headers);
				newHeaders.set('Cross-Origin-Embedder-Policy', 'require-corp');
				newHeaders.set('Cross-Origin-Opener-Policy', 'same-origin');
				
				return new Response(response.body, {
					status: response.status,
					statusText: response.statusText,
					headers: newHeaders
				});
			}).catch((error) => {
				console.error('Service Worker fetch error:', error);
				return fetch(request);
			})
		);
	} else {
		// Para requisições cross-origin, apenas faz fetch normal
		event.respondWith(fetch(request));
	}
});
