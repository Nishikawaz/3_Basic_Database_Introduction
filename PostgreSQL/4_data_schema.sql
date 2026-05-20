

-- Listado de los ENUMS para cada caso
CREATE TYPE customer_section AS ENUM ('retail', 'wholesale', 'online_only', 'vip');
CREATE TYPE product_category AS ENUM ('automotive', 'beauty', 'books', 'electronics','fashion', 'grocery', 'home', 'office', 'sports', 'toys');
CREATE TYPE order_channel AS ENUM ('web', 'mobile', 'phone', 'store');
CREATE TYPE order_status AS ENUM ('created', 'packed', 'paid', 'shipped','delivered', 'cancelled', 'refunded');
CREATE TYPE currency_code AS ENUM ('PYG', 'USD');
CREATE TYPE payment_method AS ENUM ('card', 'transfer', 'cash', 'wallet');
CREATE TYPE payment_status_check AS ENUM ('pending', 'approved', 'rejected', 'refunded');
CREATE TYPE status_actor AS ENUM('ops','payment_gateway','system','user','warehouse');
CREATE TYPE audit_responsible AS ENUM('ops','support','system'); 
CREATE TYPE order_reason AS ENUM ('chargeback', 'customer_request', 'fraud_check', 'out_of_stock', 'payment_failed', 'return','service_issue');

CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL, 
    city VARCHAR(100) NOT NULL,
    segment customer_segment NOT NULL,
    created_at TIMESTAMP NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMP, 
    CONSTRAINT chk_customer_soft_delete CHECK (
        (is_active = TRUE  AND deleted_at IS NULL) OR
        (is_active = FALSE AND deleted_at IS NOT NULL)
    )
);

CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(200) NOT NULL,
    category product_category NOT NULL,
    brand VARCHAR(100) NOT NULL,
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    unit_cost NUMERIC(12,2) NOT NULL CHECK (unit_cost > 0),
    created_at TIMESTAMP NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMP,

    CONSTRAINT chk_product_margin CHECK (unit_price > unit_cost),

    CONSTRAINT chk_product_soft_delete CHECK (
        (is_active = TRUE  AND deleted_at IS NULL) OR
        (is_active = FALSE AND deleted_at IS NOT NULL)
    )
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_datetime TIMESTAMP NOT NULL,
    "channel" order_channel NOT NULL,
    currency currency_code NOT NULL,
    current_status order_status NOT NULL,
    order_total NUMERIC(12,2) NOT NULL CHECK (order_total >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMP,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    CONSTRAINT chk_order_soft_delete CHECK (
        (is_active = TRUE  AND deleted_at IS NULL) OR
        (is_active = FALSE AND deleted_at IS NOT NULL)
    )
);

CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    discount_rate NUMERIC(5,4) NOT NULL DEFAULT 0, CHECK (discount_rate >= 0 AND discount_rate <= 0.25),
    line_total NUMERIC(12,2) NOT NULL CHECK (line_total >= 0),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    payment_datetime TIMESTAMP NOT NULL,
    "method" payment_method NOT NULL,
    payment_status payment_status_val NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    currency currency_code NOT NULL,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_status_history (
    status_history_id  INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    status order_status NOT NULL,
    changed_at TIMESTAMP NOT NULL,
    changed_by status_actor NOT NULL,
    reason order_reason,
    CONSTRAINT fk_status_history_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_audit (
    audit_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    field_name VARCHAR(100) NOT NULL CHECK (field_name IN ('current_status', 'shipping_address', 'order_total', 'notes', 'customer_phone')),
    old_value TEXT,
    new_value TEXT,
    changed_at TIMESTAMP NOT NULL,
    changed_by audit_actor NOT NULL,
    CONSTRAINT fk_audit_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);