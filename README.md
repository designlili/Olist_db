-- Create schema

CREATE SCHEMA IF NOT EXISTS olist;

-- Customers

CREATE TABLE IF NOT EXISTS olist.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state VARCHAR(2)
);

-- Geolocation

CREATE TABLE IF NOT EXISTS olist.geolocation (
    geolocation_zip_code_prefix INTEGER,
    geolocation_lat NUMERIC(10, 8),
    geolocation_lng NUMERIC(11, 8),
    geolocation_city TEXT,
    geolocation_state VARCHAR(2)
);

-- Sellers

CREATE TABLE IF NOT EXISTS olist.sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INTEGER,
    seller_city TEXT,
    seller_state VARCHAR(2)
);

-- Products

CREATE TABLE IF NOT EXISTS olist.products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name TEXT,
    product_name_lenght INTEGER,
    product_description_lenght INTEGER,
    product_photos_qty INTEGER,
    product_weight_g INTEGER,
    product_length_cm INTEGER,
    product_height_cm INTEGER,
    product_width_cm INTEGER
);

-- Category translation

CREATE TABLE IF NOT EXISTS olist.category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

-- Orders

CREATE TABLE IF NOT EXISTS olist.orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status TEXT,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Order items

CREATE TABLE IF NOT EXISTS olist.order_items (
    order_id VARCHAR(50),
    order_item_id INTEGER,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(10, 2),
    freight_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- Payments

CREATE TABLE IF NOT EXISTS olist.order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Reviews

CREATE TABLE IF NOT EXISTS olist.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- CSV import (adjust paths!)

COPY olist.customers FROM 'PATH/olist_customers.csv' CSV HEADER;
COPY olist.geolocation FROM 'PATH/olist_geolocation.csv' CSV HEADER;
COPY olist.sellers FROM 'PATH/olist_sellers.csv' CSV HEADER;
COPY olist.products FROM 'PATH/olist_products.csv' CSV HEADER;
COPY olist.category_translation FROM 'PATH/category_translation.csv' CSV HEADER;
COPY olist.orders FROM 'PATH/olist_orders.csv' CSV HEADER;
COPY olist.order_items FROM 'PATH/olist_order_items.csv' CSV HEADER;
COPY olist.order_payments FROM 'PATH/olist_order_payments.csv' CSV HEADER;
COPY olist.order_reviews FROM 'PATH/olist_order_reviews.csv' CSV HEADER;

-- Remove duplicate reviews

DELETE FROM olist.order_reviews a
USING olist.order_reviews b
WHERE a.review_id = b.review_id
AND a.ctid > b.ctid;

-- Standardize text

UPDATE olist.customers
SET customer_city = INITCAP(TRIM(customer_city));

UPDATE olist.orders
SET order_status = LOWER(TRIM(order_status));

UPDATE olist.products
SET product_category_name = LOWER(TRIM(product_category_name));

-- Missing orders

SELECT COUNT(*)
FROM olist.order_items oi
LEFT JOIN olist.orders o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Invalid delivery dates

SELECT COUNT(*)
FROM olist.orders
WHERE order_delivered_customer_date < order_purchase_timestamp;


-- Foreign keys

ALTER TABLE olist.orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES olist.customers(customer_id);

-- Indexes

CREATE INDEX idx_orders_customer
ON olist.orders(customer_id);

CREATE INDEX idx_items_order
ON olist.order_items(order_id);


-- Orders view (German)

CREATE OR REPLACE VIEW olist.v_orders_deutsch AS
SELECT
    order_id,
    CASE
        WHEN order_status = 'delivered' THEN 'Zugestellt'
        WHEN order_status = 'canceled' THEN 'Storniert'
        ELSE order_status
    END AS status
FROM olist.orders;


-- Total revenue

SELECT ROUND(SUM(price + freight_value), 2) AS revenue
FROM olist.order_items;

-- Orders per month

SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS month,
    COUNT(*) AS orders
FROM olist.orders
GROUP BY month
ORDER BY month;






























