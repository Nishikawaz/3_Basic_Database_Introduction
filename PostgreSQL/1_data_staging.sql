DROP TABLE IF EXISTS

CREATE TABLE staging_customers (
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

CREATE TABLE staging_products (
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

CREATE TABLE staging_orders (
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

CREATE TABLE staging_order_items (
    order_item_id TEXT,
    order_id TEXT,
    product_id TEXT,
    quantity TEXT,
    unit_price TEXT,
    discount_rate TEXT,
    line_total TEXT
);

CREATE TABLE staging_payments (
    payment_id TEXT,
    order_id TEXT,
    payment_datetime TEXT,
    method TEXT,
    payment_status TEXT,
    amount TEXT,
    currency TEXT
);

CREATE TABLE staging_order_status_history (
    status_history_id  TEXT,
    order_id TEXT,
    status TEXT,
    changed_at TEXT,
    changed_by TEXT,
    reason TEXT
);

