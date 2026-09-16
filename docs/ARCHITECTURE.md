# Architecture Decision Record

## Goals
1. Offline-first writes with immediate local UX.
2. Financial operations are append-only and auditable.
3. Idempotent sync using `client_transaction_id`.
4. Store-level isolation on every server query and mutation.
5. Modular code that can later support multiple branches/devices.

## Mobile
Presentation -> Application/Use Cases -> Domain -> Repositories -> SQLite/API adapters.

SQLite is the source of truth for the active device while offline. Every mutation is committed locally in one transaction and creates an outbox record in the same transaction.

## Backend
NestJS modules -> Controllers -> DTO validation -> Services -> Repositories -> PostgreSQL.
Business rules never live in controllers or Flutter widgets.

## Financial model
Sales, payments, purchases, expenses and cash movements are immutable events after posting. Corrections create compensating transactions. Historical `sale_items.cost_price` is stored at sale time.

## Sync
Push outbox operations in deterministic order. Server enforces idempotency by `(store_id, client_transaction_id)`. Pull uses a monotonic server cursor. Metadata edits may use version/updated_at conflict checks; posted financial events are not last-write-wins.

## Security
Argon2/bcrypt password hashing, short-lived access tokens, rotating refresh tokens, store-scoped authorization, rate limiting, DTO validation, audit logs, HTTPS in deployment, and no client-controlled ownership/store scope.
