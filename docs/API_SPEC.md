# دَكانة — API Specification v1

Base path: `/api/v1`

## Conventions

- JSON request/response bodies.
- UUID identifiers.
- ISO-8601 timestamps.
- Authenticated endpoints receive a short-lived JWT access token.
- Store scope is derived from authenticated membership, never trusted from the request body.
- Mutating financial requests carry `client_transaction_id` for idempotency.

## Phase 1 endpoints

### Auth

`POST /auth/register`

Request:
```json
{"name":"أحمد","phone":"0590000000","password":"..."}
```

Response: `201` with user, access token and refresh token.

`POST /auth/login`

Request:
```json
{"phone":"0590000000","password":"..."}
```

Response: `200` with user, access token and refresh token.

`POST /auth/refresh`

Request:
```json
{"refresh_token":"..."}
```

Response: `200` with rotated access/refresh tokens.

`POST /auth/logout`

Revokes the current refresh token/device session.

`GET /me`

Returns the authenticated user and active store memberships.

### Store

`POST /store`

```json
{"name":"دكان أبو محمد","phone":"0590000000","address":"غزة","currency":"ILS"}
```

The authenticated user becomes `owner` in `store_users`.

`GET /store`

Returns the active store for the current session.

`PUT /store`

Updates editable store metadata. Metadata updates use optimistic version checks.

### Customers

`GET /customers?search=&cursor=&limit=30`

Returns customers belonging to the authenticated store only.

`POST /customers`

```json
{"name":"أحمد محمد","phone":"0590000000","address":"...","notes":"...","opening_balance":0}
```

`GET /customers/:id`

Returns one store-scoped customer.

`PUT /customers/:id`

Updates metadata only. Financial balance is not edited directly.

`GET /customers/:id/statement?from=&to=&cursor=`

Returns a chronological statement generated from opening balance plus customer transactions.

## Error format

```json
{
  "statusCode": 400,
  "code": "VALIDATION_ERROR",
  "message": "...",
  "requestId": "..."
}
```

## Idempotency

For financial writes, the backend executes the complete business operation inside one PostgreSQL transaction. A repeated `(store_id, client_transaction_id)` returns the original logical result and does not create a second financial event.
