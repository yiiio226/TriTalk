/**
 * Encoding utilities
 */

/**
 * Convert hex string to base64 string.
 * Used primarily for converting MiniMax TTS audio hex to base64.
 */
export function hexToBase64(hexString: string): string {
  const bytes = new Uint8Array(
    hexString.match(/.{1,2}/g)!.map((byte) => parseInt(byte, 16))
  );
  let binary = "";
  bytes.forEach((byte) => (binary += String.fromCharCode(byte)));
  return btoa(binary);
}

/**
 * Convert ArrayBuffer to base64 string using chunked approach.
 * Handles large files efficiently by processing in chunks.
 */
export function arrayBufferToBase64(arrayBuffer: ArrayBuffer): string {
  const uint8Array = new Uint8Array(arrayBuffer);
  const CHUNK_SIZE = 65536; // 64KB chunks
  let binary = "";
  for (let i = 0; i < uint8Array.length; i += CHUNK_SIZE) {
    const chunk = uint8Array.subarray(
      i,
      Math.min(i + CHUNK_SIZE, uint8Array.length)
    );
    binary += String.fromCharCode.apply(null, Array.from(chunk));
  }
  return btoa(binary);
}
