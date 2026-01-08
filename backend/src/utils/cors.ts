/**
 * CORS utilities for streaming responses
 */

// Allowed origins for CORS
export const ALLOWED_ORIGINS = [
  "http://localhost:8080",
  "http://localhost:3000",
  "http://127.0.0.1:8080",
  "http://127.0.0.1:3000",
  // Add production domain here when deployed
  // 'https://yourdomain.com',
];

/**
 * Check if an origin is allowed.
 */
export function isOriginAllowed(origin: string): boolean {
  return (
    ALLOWED_ORIGINS.includes(origin) ||
    origin.startsWith("http://localhost:") ||
    origin.startsWith("http://127.0.0.1:")
  );
}

/**
 * Get allowed origin for CORS header.
 * Returns the origin if allowed, otherwise "null".
 */
export function getAllowedOrigin(origin: string): string {
  return isOriginAllowed(origin) ? origin : "null";
}

/**
 * Get CORS headers for streaming responses.
 * Hono's CORS middleware doesn't automatically apply to raw Response objects.
 */
export function getStreamingCorsHeaders(
  origin: string
): Record<string, string> {
  return {
    "Access-Control-Allow-Origin": getAllowedOrigin(origin),
    "Access-Control-Allow-Methods": "GET, POST, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization, X-API-Key",
  };
}
