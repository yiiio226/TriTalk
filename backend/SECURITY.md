# API Security Documentation (Updated)

## Overview
TriTalk's backend API implements **Option C: Full User Authentication**.
- **Mechanism**: Use Supabase Auth (JWT).
- **Client**: Requests must carry a valid User Token (`Authorization: Bearer <token>`).
- **Backend**: Verifies token against Supabase Auth server and optionally checks database for subscription/balance.

## Authentication Flow
1. **Frontend Login**: User logs in via Flutter App (Supabase Auth).
2. **Token Injection**: `ApiService` automatically attaches the Access Token to every request.
3. **Backend Verification**:
   - Worker receives request with Token.
   - Worker calls `supabase.auth.getUser()`.
   - Worker checks `profiles` table for user status.
   - If invalid/unauthorized, returns `401 Unauthorized`.

## Key Management

### Local Development
Configured in `.dev.vars` (do not verify this into git):
```bash
OPENROUTER_API_KEY=...
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

### Production
Set via Cloudflare Secrets:
```bash
wrangler secret put OPENROUTER_API_KEY
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_ANON_KEY
```

## CORS Configuration
Allowed origins are defined in `src/index.ts`:
- Localhost (8080, 3000)
- Production domains (add manually in `src/index.ts`)
