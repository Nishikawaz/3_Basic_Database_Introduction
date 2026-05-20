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
