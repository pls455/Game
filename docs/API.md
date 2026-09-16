# API v1 contract (initial)

## Auth
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/refresh
POST /api/v1/auth/logout
GET /api/v1/me

## Store
GET /api/v1/store
PUT /api/v1/store

## Customers
GET /api/v1/customers
POST /api/v1/customers
GET /api/v1/customers/:id
PUT /api/v1/customers/:id
GET /api/v1/customers/:id/statement
POST /api/v1/customers/:id/payments

## Products & inventory
GET /api/v1/products
POST /api/v1/products
GET /api/v1/products/:id
PUT /api/v1/products/:id
GET /api/v1/inventory

## Sales
GET /api/v1/sales
POST /api/v1/sales
GET /api/v1/sales/:id
POST /api/v1/sales/:id/return

## Purchases & suppliers
GET /api/v1/purchases
POST /api/v1/purchases
GET /api/v1/suppliers
POST /api/v1/suppliers
POST /api/v1/suppliers/:id/payments

## Expenses & cash
GET /api/v1/expenses
POST /api/v1/expenses
GET /api/v1/cash

## Reports
GET /api/v1/reports/sales
GET /api/v1/reports/profit
GET /api/v1/reports/debts
GET /api/v1/reports/inventory
GET /api/v1/reports/cash

## Sync
POST /api/v1/sync/push
POST /api/v1/sync/pull
GET /api/v1/sync/status

### Sync rules
Every write carries `client_transaction_id` (UUID). Server treats repeated IDs for the same store as the same logical operation and returns the existing result rather than inserting a duplicate. Pull responses include a monotonic cursor. Financial events are append-only after posting.
