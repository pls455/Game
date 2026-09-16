# دَكانة — ERD

## Phase 1 core

```mermaid
erDiagram
  USERS ||--o{ STORE_USERS : membership
  STORES ||--o{ STORE_USERS : has
  USERS ||--o{ STORES : owns
  STORES ||--o{ CUSTOMERS : has
  USERS ||--o{ CUSTOMERS : creates

  USERS {
    uuid id PK
    text name
    text phone UK
    text password_hash
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  STORES {
    uuid id PK
    uuid owner_id FK
    text name
    text phone
    text address
    text currency
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }

  STORE_USERS {
    uuid id PK
    uuid store_id FK
    uuid user_id FK
    text role
    timestamptz created_at
    timestamptz updated_at
  }

  CUSTOMERS {
    uuid id PK
    uuid store_id FK
    text name
    text phone
    text address
    text notes
    numeric opening_balance
    bigint version
    timestamptz created_at
    timestamptz updated_at
    timestamptz deleted_at
  }
```

## Full MVP relationship map

- `stores.owner_id -> users.id`
- `store_users.store_id -> stores.id`
- `store_users.user_id -> users.id`
- Every business table contains `store_id` for tenant isolation.
- Customers and suppliers keep opening balances as starting values; subsequent financial movement is represented by immutable transaction rows.
- Sales own sale items; purchases own purchase items.
- Inventory movement references its source operation.
- Cash movement references its source operation.
- Sync and audit records identify the store, user, and device.

## Invariants

1. A user may access data only through an active `store_users` membership.
2. Financial records are never physically deleted after posting.
3. `client_transaction_id` is unique per store for idempotent writes.
4. Historical sale cost is stored on `sale_items.cost_price`.
5. Metadata entities use versioning for conflict detection.
