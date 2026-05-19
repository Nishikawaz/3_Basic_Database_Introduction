-- Active: 1779159883170@@127.0.0.1@5432@penguin_academy_db

DROP SCHEMA IF EXISTS staging CASCADE;
CREATE SCHEMA staging;

CREATE TABLE staging.customers (
    customer_id TEXT,
    full_name TEXT,
    email TEXT,
    phone TEXT,
    city TEXT,
    segment TEXT,
    created_at TEXT,
    is_active TEXT,
    deleted_at TEXT
);

CREATE TABLE staging.products (
    product_id TEXT,
    sku TEXT,
    product_name TEXT,
    category TEXT,
    brand TEXT,
    unit_price TEXT,
    unit_cost TEXT,
    created_at TEXT,
    is_active TEXT,
    deleted_at TEXT
);

CREATE TABLE staging.orders (
    order_id TEXT,
    customer_id TEXT,
    order_datetime TEXT,
    "channel" TEXT,
    currency TEXT,
    current_status TEXT,
    is_active TEXT,
    deleted_at TEXT,
    order_total TEXT
);

CREATE TABLE staging.order_items (
    order_item_id TEXT,
    order_id TEXT,
    product_id TEXT,
    quantity TEXT,
    unit_price TEXT,
    discount_rate TEXT,
    line_total TEXT
);

CREATE TABLE staging.payments (
    payment_id TEXT,
    order_id TEXT,
    payment_datetime TEXT,
    "method" TEXT,
    payment_status TEXT,
    amount TEXT,
    currency TEXT
);

CREATE TABLE staging.order_status_history (
    status_history_id TEXT,
    order_id TEXT,
    "status" TEXT,
    changed_at TEXT,
    changed_by TEXT,
    reason TEXT
);

CREATE TABLE staging.order_audit (
    audit_id TEXT,
    order_id TEXT,
    field_name TEXT,
    old_value TEXT,
    new_value TEXT,
    changed_at TEXT,
    changed_by TEXT
);