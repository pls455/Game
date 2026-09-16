CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  phone text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE stores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES users(id),
  name text NOT NULL,
  phone text,
  address text,
  currency text NOT NULL DEFAULT 'ILS',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  deleted_at timestamptz
);

CREATE TABLE store_users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id uuid NOT NULL REFERENCES stores(id),
  user_id uuid NOT NULL REFERENCES users(id),
  role text NOT NULL CHECK (role IN ('owner','manager','cashier','viewer')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(store_id,user_id)
);

CREATE TABLE customers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id),
  name text NOT NULL, phone text, address text, notes text, opening_balance numeric(14,2) NOT NULL DEFAULT 0,
  version bigint NOT NULL DEFAULT 1, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE suppliers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id),
  name text NOT NULL, phone text, address text, notes text, opening_balance numeric(14,2) NOT NULL DEFAULT 0,
  version bigint NOT NULL DEFAULT 1, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), name text NOT NULL,
  version bigint NOT NULL DEFAULT 1, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz
);

CREATE TABLE products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), category_id uuid REFERENCES categories(id),
  name text NOT NULL, sku text, barcode text, unit text NOT NULL DEFAULT 'piece', cost_price numeric(14,2) NOT NULL DEFAULT 0,
  sale_price numeric(14,2) NOT NULL DEFAULT 0, min_stock numeric(14,3) NOT NULL DEFAULT 0, is_active boolean NOT NULL DEFAULT true,
  version bigint NOT NULL DEFAULT 1, created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz,
  UNIQUE(store_id, sku), UNIQUE(store_id, barcode)
);

CREATE TABLE sales (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), customer_id uuid REFERENCES customers(id),
  invoice_number text NOT NULL, subtotal numeric(14,2) NOT NULL, discount numeric(14,2) NOT NULL DEFAULT 0, total numeric(14,2) NOT NULL,
  paid numeric(14,2) NOT NULL DEFAULT 0, due numeric(14,2) NOT NULL DEFAULT 0, payment_type text NOT NULL,
  status text NOT NULL DEFAULT 'posted', client_transaction_id uuid NOT NULL, created_by uuid NOT NULL REFERENCES users(id),
  created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(), deleted_at timestamptz,
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE sale_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), sale_id uuid NOT NULL REFERENCES sales(id), product_id uuid NOT NULL REFERENCES products(id),
  quantity numeric(14,3) NOT NULL, unit_price numeric(14,2) NOT NULL, cost_price numeric(14,2) NOT NULL, discount numeric(14,2) NOT NULL DEFAULT 0, total numeric(14,2) NOT NULL
);

CREATE TABLE purchases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), supplier_id uuid REFERENCES suppliers(id),
  invoice_number text NOT NULL, subtotal numeric(14,2) NOT NULL, discount numeric(14,2) NOT NULL DEFAULT 0, total numeric(14,2) NOT NULL,
  paid numeric(14,2) NOT NULL DEFAULT 0, due numeric(14,2) NOT NULL DEFAULT 0, payment_type text NOT NULL,
  client_transaction_id uuid NOT NULL, created_by uuid NOT NULL REFERENCES users(id), created_at timestamptz NOT NULL DEFAULT now(), updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE purchase_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), purchase_id uuid NOT NULL REFERENCES purchases(id), product_id uuid NOT NULL REFERENCES products(id),
  quantity numeric(14,3) NOT NULL, unit_cost numeric(14,2) NOT NULL, total numeric(14,2) NOT NULL
);

CREATE TABLE customer_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), customer_id uuid NOT NULL REFERENCES customers(id),
  type text NOT NULL CHECK(type IN ('sale','payment','return','adjustment','opening_balance')), amount numeric(14,2) NOT NULL,
  reference_type text, reference_id uuid, note text, client_transaction_id uuid, created_at timestamptz NOT NULL DEFAULT now(), created_by uuid REFERENCES users(id),
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE supplier_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), supplier_id uuid NOT NULL REFERENCES suppliers(id),
  type text NOT NULL CHECK(type IN ('purchase','payment','return','adjustment','opening_balance')), amount numeric(14,2) NOT NULL,
  reference_type text, reference_id uuid, note text, client_transaction_id uuid, created_at timestamptz NOT NULL DEFAULT now(), created_by uuid REFERENCES users(id),
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE inventory_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), product_id uuid NOT NULL REFERENCES products(id),
  type text NOT NULL CHECK(type IN ('opening','purchase','sale','sale_return','purchase_return','adjustment')), quantity numeric(14,3) NOT NULL,
  unit_cost numeric(14,2), reference_type text, reference_id uuid, client_transaction_id uuid, created_at timestamptz NOT NULL DEFAULT now(), created_by uuid REFERENCES users(id),
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), category_id uuid, amount numeric(14,2) NOT NULL,
  description text, payment_method text NOT NULL, client_transaction_id uuid NOT NULL, created_at timestamptz NOT NULL DEFAULT now(), created_by uuid REFERENCES users(id),
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE cash_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), type text NOT NULL,
  amount numeric(14,2) NOT NULL, reference_type text, reference_id uuid, note text, client_transaction_id uuid,
  created_at timestamptz NOT NULL DEFAULT now(), created_by uuid REFERENCES users(id), UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES users(id), store_id uuid NOT NULL REFERENCES stores(id),
  name text NOT NULL, last_seen_at timestamptz, created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sync_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), device_id uuid NOT NULL REFERENCES devices(id), store_id uuid NOT NULL REFERENCES stores(id),
  client_transaction_id uuid NOT NULL, entity_type text NOT NULL, operation text NOT NULL, payload jsonb NOT NULL,
  status text NOT NULL DEFAULT 'pending', attempts integer NOT NULL DEFAULT 0, last_error text, created_at timestamptz NOT NULL DEFAULT now(), synced_at timestamptz,
  UNIQUE(store_id, client_transaction_id)
);

CREATE TABLE audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), store_id uuid NOT NULL REFERENCES stores(id), user_id uuid REFERENCES users(id), device_id uuid REFERENCES devices(id),
  action text NOT NULL, entity_type text NOT NULL, entity_id uuid, metadata jsonb, created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(), user_id uuid NOT NULL REFERENCES users(id), device_id uuid REFERENCES devices(id), token_hash text NOT NULL,
  expires_at timestamptz NOT NULL, revoked_at timestamptz, created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_customers_store ON customers(store_id);
CREATE INDEX idx_products_store ON products(store_id);
CREATE INDEX idx_sales_store_date ON sales(store_id, created_at);
CREATE INDEX idx_customer_tx_store_customer_date ON customer_transactions(store_id, customer_id, created_at);
CREATE INDEX idx_inventory_store_product_date ON inventory_transactions(store_id, product_id, created_at);
CREATE INDEX idx_cash_store_date ON cash_transactions(store_id, created_at);
CREATE INDEX idx_audit_store_date ON audit_logs(store_id, created_at);
