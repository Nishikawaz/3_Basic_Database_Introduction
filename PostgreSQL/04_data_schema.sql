DROP TABLE IF EXISTS customers, order_audit, order_items, order_status_history, orders, payments, products CASCADE;
DROP TYPE IF EXISTS order_reason, audit_responsible, status_actor, payment_status_check, payment_method, currency_code, order_status, order_channel, product_category, customer_section CASCADE;

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

-- Creación de las tablas

-- Tablas de Customers
CREATE TABLE customers (
    customer_id INTEGER PRIMARY KEY,
    full_name VARCHAR(200) NOT NULL,
    email VARCHAR(200) NOT NULL UNIQUE,
    phone VARCHAR(25) NOT NULL,
    city VARCHAR(150) NOT NULL,
    segment customer_section NOT NULL,
    created_at TIMESTAMP NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMP,
    CONSTRAINT chk_customer_soft_delete CHECK (
        (is_active = TRUE  AND deleted_at IS NULL) OR
        (is_active = FALSE AND deleted_at IS NOT NULL)
    )
);

-- Tabla de Products
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category product_category NOT NULL,
    brand VARCHAR(80) NOT NULL,
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

-- Tabla de Orders
CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    order_datetime TIMESTAMP NOT NULL,
    channel order_channel NOT NULL,
    currency currency_code NOT NULL,
    current_status order_status NOT NULL,
    order_total NUMERIC(12,2) NOT NULL CHECK (order_total >= 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    deleted_at TIMESTAMP,
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    CONSTRAINT chk_order_soft_delete CHECK (
        (is_active = TRUE  AND deleted_at IS NULL) OR
        (is_active = FALSE AND deleted_at IS NOT NULL)
    )
);

-- Tabla de Order items
CREATE TABLE order_items (
    order_item_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(12,2) NOT NULL CHECK (unit_price > 0),
    discount_rate NUMERIC(5,4) NOT NULL DEFAULT 0 CHECK (discount_rate >= 0 AND discount_rate <= 1.00),
    line_total NUMERIC(12,2) NOT NULL CHECK (line_total >= 0),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders(order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Tabla de Payments
CREATE TABLE payments (
    payment_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    payment_datetime TIMESTAMP NOT NULL,
    method payment_method NOT NULL,
    payment_status payment_status_check NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    currency currency_code NOT NULL,
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Tabla de Order Status History
CREATE TABLE order_status_history (
    status_history_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    status order_status NOT NULL,
    changed_at TIMESTAMP NOT NULL,
    changed_by status_actor NOT NULL,
    reason order_reason,
    CONSTRAINT fk_status_history_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Tabla de Order Audit
CREATE TABLE order_audit (
    audit_id INTEGER PRIMARY KEY,
    order_id INTEGER NOT NULL,
    field_name VARCHAR(100) NOT NULL CHECK (
        field_name IN ('current_status', 'shipping_address', 'order_total', 'notes', 'customer_phone')
    ),
    old_value TEXT,
    new_value TEXT,
    changed_at TIMESTAMP NOT NULL,
    changed_by audit_responsible NOT NULL,
    CONSTRAINT fk_audit_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);


CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_status_history_order_id ON order_status_history(order_id);
CREATE INDEX idx_audit_order_id ON order_audit(order_id);

CREATE INDEX idx_orders_current_status ON orders(current_status);
CREATE INDEX idx_orders_datetime ON orders(order_datetime DESC);
CREATE INDEX idx_payments_status ON payments(payment_status);
CREATE INDEX idx_orders_active_customer ON orders(customer_id) WHERE is_active = TRUE;