# AuthApp

iOS client for the DevMDS "Car Building Commissions API" test environment (`https://site.api-test.devmds.com`), built for a Swift developer technical assessment. Login, view your commissions, log out — with proper session handling and no shortcuts around security or testing.

## Requirements

- Xcode 16+
- iOS 18+
- Swift 6

## Setup

1. Clone the repo and open `AuthApp.xcodeproj`.
2. You'll need a test account for the API. Create `Secrets.local.xcconfig` at the project root (it's git-ignored, so it never gets committed) with:
   ```
   TEST_ACCOUNT_EMAIL = your.test.account@example.com
   TEST_ACCOUNT_PASSWORD = yourTestPassword
   ```
   Wire these into the scheme's environment variables if you want the login form pre-filled for manual testing. Don't hardcode them anywhere in source.
3. Build and run. Cmd+U for the test suite.

## The API contract

I verified this directly against the live Swagger UI (`/docs`) rather than assuming anything — the assessment specifically calls out not inferring undocumented fields, and a couple of things here genuinely aren't documented.

| Operation | Method & Path | Auth | Request Body | Success | Documented Errors |
|---|---|---|---|---|---|
| Login | `POST /auth/login` | none | `{ email, password }` | `200 { accessToken }` (JWT) | `401 { message, statusCode }` |
| List commissions | `GET /commissions` | Bearer | — | `200 [Commission]` | `401` |
| Get commission | `GET /commissions/{id}` | Bearer | `id` (path) | `200 Commission` | `404`, and in practice `401` too (marked "Undocumented" in the spec itself) |

Auth is a plain Bearer token: `Authorization: Bearer <accessToken>`.

A commission looks like this (observed from a live authenticated call — there's no schema for it in Swagger):
```json
{
  "id": "9ef0dc02-8133-4422-9dbc-bca38b156a79",
  "carModel": "Mustang GT",
  "carBrand": "Ford",
  "buildCost": "45000.00",
  "commissionRate": "3.00",
  "commissionAmount": "1350.00",
  "status": "pending",
  "createdAt": "2026-07-18T19:03:34.935Z"
}
```

A few things worth flagging about how this differs from what's documented:

- **There's no schema for `Commission` at all** in Swagger, only `LoginDto` and `AuthResponseDto`. The shape above came from an actual authenticated call during testing, not the docs. Decoding is written to tolerate that — an unexpected or missing field shouldn't take down the whole list.
- **The numeric-looking fields are strings**, not numbers (`"buildCost": "45000.00"`). Decoding them as `Double` would throw. They come in as `String` and get converted to `Decimal` further up, with a fallback if that ever fails.
- **`status` is an open-ended string.** Only `"pending"` has shown up so far, so it's modeled with a fallback case rather than a fixed enum — an unfamiliar value later shouldn't break decoding.
- **There's no logout, register, or refresh endpoint**, even though the API's own description mentions "Register." Logout here just clears the local session (Keychain) — nothing is called on the server.

## Architecture

Clean Architecture-ish, MVVM-C on top:

```
App/        composition root + coordinator
Core/       networking, session, error types, utilities — no UI, no feature-specific logic
Shared/     reusable UI components and design tokens
Features/   one folder per feature — View / ViewModel / Repository / Models / Services / Coordinator
Tests/      mocks, fixtures, and test suites
```

The rule that matters most: Views only know about ViewModels, ViewModels only know about repository protocols, repositories only know about `APIClientProtocol`, and `APIClient` is the only thing that ever touches `URLSession`. No singletons — everything gets passed in through initializers.

A few pieces worth knowing about in `Core/Networking`:

- **`HTTPRequestBuilder`** is the one place a `URLRequest` gets assembled, including the `Authorization` header. Worth calling out because of something that actually happened while verifying the API by hand: pasting a token with its surrounding quotes into Swagger's "Authorize" field produced `Authorization: Bearer "eyJ..."`, and the API correctly rejected it. Having exactly one code path build that header rules out that whole class of bug, and there's a test (`attachesAuthorizationHeader`) asserting the header comes out clean.
- **`NetworkError`** is a closed set of failure cases (transport, HTTP status, decoding, unauthorized, etc.) with no user-facing copy in it — that's a separate layer's job, so this type can stay dumb and just classify what happened.
- **`AuthorizationInterceptor`** is how `APIClient` gets a bearer token without knowing Keychain or any session state exists. Right now it's a no-op (login doesn't need a token); the session layer plugs in here once it exists.
- **`RetryPolicy`** only retries actual connectivity failures, never HTTP errors or bad JSON — retrying a 401 wouldn't accomplish anything except delay telling the user it failed.
- **`Logger`** wraps `os.Logger` and refuses to emit anything marked sensitive outside of a masked placeholder, even in debug. It's the only thing in the app allowed to log at all.

## Testing

Uses Swift Testing rather than XCTest — mostly a readability preference, XCTest would've worked fine too. Everything runs against a stubbed `URLProtocol`, never the live API, so the suite is deterministic and doesn't care whether the API happens to be up.

Covered so far:
- successful decode of a login-shaped response
- 401 → `NetworkError.unauthorized`
- an unexpected status code (500) → `NetworkError.http`
- a malformed body → `NetworkError.decoding`, without crashing
- a protected call with no token available fails immediately, no network call made
- the Authorization header is well-formed (no stray quotes — see above)

## Known limitations

- No documented schema for `Commission`, so decoding is defensive rather than guaranteed to hold up against future changes to the API.
- No server-side logout, registration, or refresh endpoint exists right now — logout only clears what's stored locally.
- A stored token means "this device was logged in before," not "this token still works" — validity only gets confirmed the next time a protected call is actually made.
