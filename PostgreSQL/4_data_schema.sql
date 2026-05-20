

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
