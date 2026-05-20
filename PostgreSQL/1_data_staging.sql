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
