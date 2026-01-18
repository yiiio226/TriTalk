/**
 * GCP Service Account Authentication for Cloudflare Workers
 * Uses Web Crypto API for RS256 JWT signing (no Node.js dependencies)
 */

interface JWTClaims {
  iss: string;
  scope: string;
  aud: string;
  exp: number;
  iat: number;
}

/**
 * Base64URL encode a string or ArrayBuffer
 */
function base64urlEncode(data: string | ArrayBuffer): string {
  let str: string;
  if (typeof data === "string") {
    str = btoa(data);
  } else {
    const bytes = new Uint8Array(data);
    let binary = "";
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    str = btoa(binary);
  }
  return str.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
}

/**
 * Parse PEM private key and extract the DER-encoded key data
 */
function parsePEMPrivateKey(pem: string): ArrayBuffer {
  // Handle escaped newlines from environment variable
  const normalizedPem = pem.replace(/\\n/g, "\n");

  // Remove PEM header/footer and newlines
  const pemContent = normalizedPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");

  // Decode base64 to binary
  const binaryString = atob(pemContent);
  const bytes = new Uint8Array(binaryString.length);
  for (let i = 0; i < binaryString.length; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes.buffer;
}

/**
 * Create a signed JWT using RS256 algorithm with Web Crypto API
 */
async function createSignedJWT(
  claims: JWTClaims,
  privateKeyPem: string,
): Promise<string> {
  console.log("[GCP Auth] Creating signed JWT", {
    issuer: claims.iss,
    scope: claims.scope,
    expiresIn: claims.exp - claims.iat,
  });

  // JWT Header
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  // Encode header and claims
  const encodedHeader = base64urlEncode(JSON.stringify(header));
  const encodedClaims = base64urlEncode(JSON.stringify(claims));
  const signingInput = `${encodedHeader}.${encodedClaims}`;

  // Import the private key
  console.log("[GCP Auth] Importing private key...");
  const keyData = parsePEMPrivateKey(privateKeyPem);
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );
  console.log("[GCP Auth] Private key imported successfully");

  // Sign the JWT
  console.log("[GCP Auth] Signing JWT...");
  const encoder = new TextEncoder();
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    encoder.encode(signingInput),
  );

  // Encode signature and create final JWT
  const encodedSignature = base64urlEncode(signature);
  console.log("[GCP Auth] JWT created successfully");
  return `${signingInput}.${encodedSignature}`;
}

interface TokenResponse {
  access_token: string;
  token_type: string;
  expires_in: number;
}

/**
 * Get a GCP Access Token using Service Account credentials.
 *
 * @param clientEmail - Service Account email address
 * @param privateKey - Service Account private key (PEM format)
 * @param scopes - OAuth2 scopes to request (array or space-separated string)
 * @returns Access token string
 */
export async function getGCPAccessToken(
  clientEmail: string,
  privateKey: string,
  scopes: string | string[] = "https://www.googleapis.com/auth/cloud-platform",
): Promise<string> {
  console.log("[GCP Auth] Getting access token", {
    clientEmail,
    scopes: Array.isArray(scopes) ? scopes : [scopes],
  });

  const scopeString = Array.isArray(scopes) ? scopes.join(" ") : scopes;

  const now = Math.floor(Date.now() / 1000);
  const claims: JWTClaims = {
    iss: clientEmail,
    scope: scopeString,
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600, // 1 hour expiry
    iat: now,
  };

  // Create signed JWT
  const jwt = await createSignedJWT(claims, privateKey);

  // Exchange JWT for access token
  console.log("[GCP Auth] Exchanging JWT for access token...");
  const tokenStartTime = Date.now();
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  console.log(
    `[GCP Auth] Token endpoint responded in ${Date.now() - tokenStartTime}ms with status ${tokenResponse.status}`,
  );

  if (!tokenResponse.ok) {
    const errorText = await tokenResponse.text();
    console.error("[GCP Auth] Failed to get access token", {
      status: tokenResponse.status,
      statusText: tokenResponse.statusText,
      errorBody: errorText,
    });
    throw new Error(
      `Failed to get GCP access token: ${tokenResponse.status} ${tokenResponse.statusText} - ${errorText}`,
    );
  }

  const tokenData = (await tokenResponse.json()) as TokenResponse;
  console.log("[GCP Auth] Access token obtained successfully", {
    tokenType: tokenData.token_type,
    expiresIn: tokenData.expires_in,
  });
  return tokenData.access_token;
}
