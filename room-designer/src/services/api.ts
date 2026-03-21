const BASE_URL = '/api/v1';

// Returns the server origin (for prepending to relative asset URLs)
export function getServerUrl(): string {
  return window.location.origin;
}

let cachedToken: string | null = null;

function getToken(): string | null {
  if (cachedToken) return cachedToken;
  const params = new URLSearchParams(window.location.search);
  return params.get('token');
}

export function setToken(token: string) {
  cachedToken = token;
}

function authHeaders(): Record<string, string> {
  const token = getToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
  };
  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }
  return headers;
}

async function handleResponse<T>(response: Response): Promise<T> {
  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`API error ${response.status}: ${errorBody}`);
  }
  return response.json();
}

export async function get<T>(path: string): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    method: 'GET',
    headers: authHeaders(),
  });
  return handleResponse<T>(response);
}

export async function post<T>(path: string, body?: unknown): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    method: 'POST',
    headers: authHeaders(),
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  return handleResponse<T>(response);
}

export async function put<T>(path: string, body?: unknown): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    method: 'PUT',
    headers: authHeaders(),
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  return handleResponse<T>(response);
}

export async function del<T>(path: string): Promise<T> {
  const response = await fetch(`${BASE_URL}${path}`, {
    method: 'DELETE',
    headers: authHeaders(),
  });
  return handleResponse<T>(response);
}

// Auto-login for dev testing (when no token in URL)
export async function devAutoLogin(): Promise<string | null> {
  try {
    const resp = await fetch(`${BASE_URL}/auth/signin`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: 'buyer@test.com', password: '123456' }),
    });
    if (!resp.ok) return null;
    const data = await resp.json();
    const token = data?.token?.accessToken;
    if (token) {
      cachedToken = token;
      return token;
    }
    return null;
  } catch {
    return null;
  }
}

// --- Showrooms ---

export function getShowrooms(filters?: Record<string, string>) {
  const params = filters ? '?' + new URLSearchParams(filters).toString() : '';
  return get<any[]>(`/showrooms${params}`);
}

export function getShowroomCategories() {
  return get<any[]>('/showrooms/categories');
}

export function getShowroom(id: string) {
  return get<any>(`/showrooms/${id}`);
}

// --- Products ---

export function getProducts(filters?: Record<string, string>) {
  const params = filters ? '?' + new URLSearchParams(filters).toString() : '';
  return get<any[]>(`/products${params}`);
}

export function searchProducts(q: string) {
  return get<any[]>(`/products/search?q=${encodeURIComponent(q)}`);
}

export function getProductCategories() {
  return get<any[]>('/products/categories');
}

export function getSimilarProducts(id: string) {
  return get<any[]>(`/products/similar/${id}`);
}

// --- User Designs ---

export function getUserDesigns() {
  return get<any[]>('/user-designs');
}

export function getDesign(id: string) {
  return get<any>(`/user-designs/${id}`);
}

export function createDesign(showroomId: string, name: string) {
  return post<any>('/user-designs', { showroomId, name });
}

export function updateDesign(id: string, data: Record<string, unknown>) {
  return put<any>(`/user-designs/${id}`, data);
}

export function saveDesignItems(designId: string, items: any[]) {
  return put<any>(`/user-designs/${designId}/items`, { items });
}

export function deleteDesign(id: string) {
  return del<any>(`/user-designs/${id}`);
}

// --- Wishlist ---

export function getWishlistPreview(designId: string) {
  return get<any>(`/wishlist/from-design/${designId}`);
}

export function saveWishlist(designId: string) {
  return post<any>(`/wishlist/from-design/${designId}`);
}
