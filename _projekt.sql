/* ============================================================
   OLIST BRAZILIAN E-COMMERCE DATASET
   PostgreSQL Data Cleaning, Modeling and Analysis
   ============================================================

   Beschreibung:
   In diesem Projekt wird das Olist Brazilian E-Commerce Dataset
   in PostgreSQL importiert, bereinigt, strukturiert und für
   Analysen aufbereitet.

   Inhalte:
   - Schema-Erstellung
   - Tabellenaufbau
   - CSV-Import
   - Datenbereinigung
   - Datenqualitätsprüfungen
   - Fremdschlüssel und Indizes
   - Übersetzungstabellen
   - Reporting-Views
   - Analyseabfragen
   ============================================================ */


/* ============================================================
   1. SCHEMA
   ============================================================ */

CREATE SCHEMA IF NOT EXISTS olist;


/* ============================================================
   2. TABELLEN
   ============================================================ */

-- Customers
CREATE TABLE IF NOT EXISTS olist.customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INTEGER,
    customer_city TEXT,
    customer_state VARCHAR(2)
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

-- Category translation (PT -> EN)
CREATE TABLE IF NOT EXISTS olist.category_translation (
    product_category_name TEXT PRIMARY KEY,
    product_category_name_english TEXT
);

-- Category translation (EN -> DE)
CREATE TABLE IF NOT EXISTS olist.category_translation_de (
    category_en TEXT PRIMARY KEY,
    category_de TEXT
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

-- Order payments
CREATE TABLE IF NOT EXISTS olist.order_payments (
    order_id VARCHAR(50),
    payment_sequential INTEGER,
    payment_type TEXT,
    payment_installments INTEGER,
    payment_value NUMERIC(10, 2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- Order reviews
-- intentionally without primary key to allow safe import
CREATE TABLE IF NOT EXISTS olist.order_reviews (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INTEGER,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);


/* ============================================================
   3. CSV IMPORT
   ============================================================ */

-- Adjust file paths before execution

COPY olist.customers
FROM 'PATH/olist_customers_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.sellers
FROM 'PATH/olist_sellers_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.products
FROM 'PATH/olist_products_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.category_translation
FROM 'PATH/product_category_name_translation.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.orders
FROM 'PATH/olist_orders_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.order_items
FROM 'PATH/olist_order_items_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.order_payments
FROM 'PATH/olist_order_payments_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY olist.order_reviews
FROM 'PATH/olist_order_reviews_dataset.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');


/* ============================================================
   4. IMPORT CHECKS AND REVIEW CLEANING
   ============================================================ */

-- Check duplicate review IDs
SELECT
    review_id,
    COUNT(*) AS anzahl
FROM olist.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- Remove duplicate reviews
DELETE FROM olist.order_reviews a
USING olist.order_reviews b
WHERE a.review_id = b.review_id
  AND a.ctid > b.ctid;

-- Check for missing review IDs
SELECT *
FROM olist.order_reviews
WHERE review_id IS NULL;


/* ============================================================
   5. DATA CLEANING AND STANDARDIZATION
   ============================================================ */

-- Standardize city names
UPDATE olist.customers
SET customer_city = INITCAP(TRIM(customer_city))
WHERE customer_city IS NOT NULL;

UPDATE olist.sellers
SET seller_city = INITCAP(TRIM(seller_city))
WHERE seller_city IS NOT NULL;

-- Standardize status and categories
UPDATE olist.orders
SET order_status = LOWER(TRIM(order_status))
WHERE order_status IS NOT NULL;

UPDATE olist.products
SET product_category_name = LOWER(TRIM(product_category_name))
WHERE product_category_name IS NOT NULL;

UPDATE olist.category_translation
SET product_category_name = LOWER(TRIM(product_category_name)),
    product_category_name_english = LOWER(TRIM(product_category_name_english))
WHERE product_category_name IS NOT NULL
   OR product_category_name_english IS NOT NULL;

-- Fix known typos in English category names
UPDATE olist.category_translation
SET product_category_name_english = 'construction_tools_garden'
WHERE product_category_name_english = 'costruction_tools_garden';

UPDATE olist.category_translation
SET product_category_name_english = 'construction_tools_tools'
WHERE product_category_name_english = 'costruction_tools_tools';

UPDATE olist.category_translation
SET product_category_name_english = 'fashion_female_clothing'
WHERE product_category_name_english = 'fashio_female_clothing';

UPDATE olist.category_translation
SET product_category_name_english = 'home_comfort'
WHERE product_category_name_english = 'home_confort';


/* ============================================================
   5.1 GERMAN CATEGORY TRANSLATION TABLE
   ============================================================ */

INSERT INTO olist.category_translation_de (category_en, category_de) VALUES
    ('bed_bath_table', 'Bett, Bad & Tisch'),
    ('health_beauty', 'Gesundheit & Schönheit'),
    ('sports_leisure', 'Sport & Freizeit'),
    ('furniture_decor', 'Möbel & Dekor'),
    ('computers_accessories', 'Computer & Zubehör'),
    ('housewares', 'Haushaltswaren'),
    ('watches_gifts', 'Uhren & Geschenke'),
    ('telephony', 'Telefonie'),
    ('auto', 'Auto & Zubehör'),
    ('toys', 'Spielzeug'),
    ('cool_stuff', 'Trendprodukte'),
    ('garden_tools', 'Gartenwerkzeuge'),
    ('perfumery', 'Parfümerie'),
    ('baby', 'Baby'),
    ('electronics', 'Elektronik'),
    ('stationery', 'Schreibwaren'),
    ('fashion_bags_accessories', 'Taschen & Accessoires'),
    ('pet_shop', 'Tierbedarf'),
    ('home_appliances', 'Haushaltsgeräte'),
    ('home_appliances_2', 'Haushaltsgeräte 2'),
    ('musical_instruments', 'Musikinstrumente'),
    ('books_general_interest', 'Bücher allgemein'),
    ('books_technical', 'Fachbücher'),
    ('books_imported', 'Importierte Bücher'),
    ('construction_tools_construction', 'Bauwerkzeuge'),
    ('construction_tools_lights', 'Beleuchtung'),
    ('construction_tools_safety', 'Sicherheitsausrüstung'),
    ('construction_tools_garden', 'Garten-Bauwerkzeuge'),
    ('construction_tools_tools', 'Werkzeuge'),
    ('food', 'Lebensmittel'),
    ('food_drink', 'Lebensmittel & Getränke'),
    ('drinks', 'Getränke'),
    ('industry_commerce_and_business', 'Industrie & Gewerbe'),
    ('luggage_accessories', 'Reisegepäck & Zubehör'),
    ('market_place', 'Marktplatz'),
    ('music', 'Musik'),
    ('cine_photo', 'Film & Foto'),
    ('party_supplies', 'Partybedarf'),
    ('christmas_supplies', 'Weihnachtsartikel'),
    ('flowers', 'Blumen'),
    ('diapers_and_hygiene', 'Windeln & Hygiene'),
    ('fashion_shoes', 'Schuhe'),
    ('fashion_underwear_beach', 'Unterwäsche & Bademode'),
    ('fashion_male_clothing', 'Herrenbekleidung'),
    ('fashion_female_clothing', 'Damenbekleidung'),
    ('fashion_children_clothes', 'Kinderkleidung'),
    ('fashion_sport', 'Sportbekleidung'),
    ('fashion_glasses', 'Brillen'),
    ('home_comfort', 'Wohnkomfort'),
    ('home_comfort_2', 'Wohnkomfort 2'),
    ('small_appliances', 'Kleingeräte'),
    ('small_appliances_home_oven_and_coffee', 'Küchengeräte'),
    ('air_conditioning', 'Klimaanlagen'),
    ('fixed_telephony', 'Festnetztelefonie'),
    ('tablets_printing_image', 'Tablets, Druck & Bild'),
    ('signaling_and_security', 'Signaltechnik & Sicherheit'),
    ('security_and_services', 'Sicherheit & Dienstleistungen'),
    ('art', 'Kunst'),
    ('arts_and_craftmanship', 'Kunsthandwerk'),
    ('audio', 'Audio'),
    ('cds_dvds_musicals', 'CDs, DVDs & Musicals'),
    ('dvds_blu_ray', 'DVD & Blu-ray'),
    ('home_construction', 'Hausbau'),
    ('furniture_bedroom', 'Schlafzimmermöbel'),
    ('furniture_living_room', 'Wohnzimmermöbel'),
    ('furniture_office', 'Büromöbel'),
    ('furniture_mattress_and_upholstery', 'Matratzen & Polster'),
    ('office_furniture', 'Büromöbel'),
    ('kitchen_dining_laundry_garden_furniture', 'Küchen-, Ess-, Wasch- & Gartenmöbel'),
    ('la_cuisine', 'Küche'),
    ('pc_gamer', 'Gaming-PC'),
    ('portable_kitchen_and_food_preparers', 'Tragbare Küchengeräte & Lebensmittelzubereiter'),
    ('computers', 'Computer'),
    ('consoles_games', 'Konsolen & Spiele'),
    ('unknown', 'Unbekannt')
ON CONFLICT (category_en) DO NOTHING;


/* ============================================================
   6. DATA QUALITY CHECKS
   ============================================================ */

-- Missing orders for order items
SELECT COUNT(*) AS fehlende_orders
FROM olist.order_items oi
LEFT JOIN olist.orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Missing products for order items
SELECT COUNT(*) AS fehlende_produkte
FROM olist.order_items oi
LEFT JOIN olist.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Missing sellers for order items
SELECT COUNT(*) AS fehlende_seller
FROM olist.order_items oi
LEFT JOIN olist.sellers s
    ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- Missing customers for orders
SELECT COUNT(*) AS fehlende_kunden
FROM olist.orders o
LEFT JOIN olist.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Invalid delivery timestamps
SELECT COUNT(*) AS unplausible_lieferungen
FROM olist.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date < order_purchase_timestamp;

-- Invalid approval timestamps
SELECT COUNT(*) AS unplausible_freigaben
FROM olist.orders
WHERE order_approved_at IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_approved_at < order_purchase_timestamp;

-- Missing categories between products and category_translation
SELECT DISTINCT
    p.product_category_name
FROM olist.products p
LEFT JOIN olist.category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND ct.product_category_name IS NULL
ORDER BY p.product_category_name;

-- Add missing categories
INSERT INTO olist.category_translation (
    product_category_name,
    product_category_name_english
)
VALUES
    ('pc_gamer', 'pc_gamer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers')
ON CONFLICT (product_category_name) DO NOTHING;

-- Re-check missing categories
SELECT DISTINCT
    p.product_category_name
FROM olist.products p
LEFT JOIN olist.category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND ct.product_category_name IS NULL
ORDER BY p.product_category_name;

-- Count remaining missing categories
SELECT COUNT(DISTINCT p.product_category_name) AS fehlende_kategorien
FROM olist.products p
LEFT JOIN olist.category_translation ct
    ON p.product_category_name = ct.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND ct.product_category_name IS NULL;

-- Check English categories without German translation
SELECT DISTINCT
    ct.product_category_name_english
FROM olist.category_translation ct
LEFT JOIN olist.category_translation_de de
    ON ct.product_category_name_english = de.category_en
WHERE ct.product_category_name_english IS NOT NULL
  AND de.category_en IS NULL
ORDER BY ct.product_category_name_english;


/* ============================================================
   7. FOREIGN KEYS
   ============================================================ */

-- products -> category_translation
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_products_category'
    ) THEN
        ALTER TABLE olist.products
        ADD CONSTRAINT fk_products_category
        FOREIGN KEY (product_category_name)
        REFERENCES olist.category_translation(product_category_name)
        NOT VALID;
    END IF;
END $$;

ALTER TABLE olist.products
VALIDATE CONSTRAINT fk_products_category;

-- Remaining foreign keys
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_orders_customer'
    ) THEN
        ALTER TABLE olist.orders
        ADD CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES olist.customers(customer_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_items_order'
    ) THEN
        ALTER TABLE olist.order_items
        ADD CONSTRAINT fk_items_order
        FOREIGN KEY (order_id)
        REFERENCES olist.orders(order_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_items_product'
    ) THEN
        ALTER TABLE olist.order_items
        ADD CONSTRAINT fk_items_product
        FOREIGN KEY (product_id)
        REFERENCES olist.products(product_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_items_seller'
    ) THEN
        ALTER TABLE olist.order_items
        ADD CONSTRAINT fk_items_seller
        FOREIGN KEY (seller_id)
        REFERENCES olist.sellers(seller_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_payments_order'
    ) THEN
        ALTER TABLE olist.order_payments
        ADD CONSTRAINT fk_payments_order
        FOREIGN KEY (order_id)
        REFERENCES olist.orders(order_id);
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'fk_reviews_order'
    ) THEN
        ALTER TABLE olist.order_reviews
        ADD CONSTRAINT fk_reviews_order
        FOREIGN KEY (order_id)
        REFERENCES olist.orders(order_id);
    END IF;
END $$;


/* ============================================================
   8. INDEXES
   ============================================================ */

CREATE INDEX IF NOT EXISTS idx_orders_customer
    ON olist.orders(customer_id);

CREATE INDEX IF NOT EXISTS idx_orders_purchase_timestamp
    ON olist.orders(order_purchase_timestamp);

CREATE INDEX IF NOT EXISTS idx_items_order
    ON olist.order_items(order_id);

CREATE INDEX IF NOT EXISTS idx_items_product
    ON olist.order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_items_seller
    ON olist.order_items(seller_id);

CREATE INDEX IF NOT EXISTS idx_payments_order
    ON olist.order_payments(order_id);

CREATE INDEX IF NOT EXISTS idx_reviews_order
    ON olist.order_reviews(order_id);

CREATE INDEX IF NOT EXISTS idx_customers_city
    ON olist.customers(customer_city);


/* ============================================================
   9. UPDATE STATISTICS
   ============================================================ */

ANALYZE;


/* ============================================================
   10. GERMAN REPORTING VIEWS
   ============================================================ */

-- Orders in German
DROP VIEW IF EXISTS olist.v_orders_deutsch CASCADE;

CREATE OR REPLACE VIEW olist.v_orders_deutsch AS
SELECT
    o.order_id,
    o.customer_id,
    CASE
        WHEN o.order_status = 'delivered'   THEN 'Zugestellt'
        WHEN o.order_status = 'shipped'     THEN 'Versendet'
        WHEN o.order_status = 'canceled'    THEN 'Storniert'
        WHEN o.order_status = 'invoiced'    THEN 'In Rechnung gestellt'
        WHEN o.order_status = 'processing'  THEN 'In Bearbeitung'
        WHEN o.order_status = 'approved'    THEN 'Genehmigt'
        WHEN o.order_status = 'created'     THEN 'Erstellt'
        WHEN o.order_status = 'unavailable' THEN 'Nicht verfügbar'
        ELSE COALESCE(o.order_status, 'Unbekannt')
    END AS bestellstatus,
    o.order_purchase_timestamp      AS kaufdatum,
    o.order_approved_at             AS freigegeben_am,
    o.order_delivered_carrier_date  AS an_versanddienst_uebergeben_am,
    o.order_delivered_customer_date AS geliefert_am,
    o.order_estimated_delivery_date AS voraussichtliches_lieferdatum
FROM olist.orders o;

-- Payments in German
DROP VIEW IF EXISTS olist.v_payments_deutsch;

CREATE OR REPLACE VIEW olist.v_payments_deutsch AS
SELECT
    op.order_id,
    CASE
        WHEN op.payment_type = 'credit_card' THEN 'Kreditkarte'
        WHEN op.payment_type = 'debit_card'  THEN 'Debitkarte'
        WHEN op.payment_type = 'voucher'     THEN 'Gutschein'
        WHEN op.payment_type = 'boleto'      THEN 'Boleto'
        WHEN op.payment_type = 'not_defined' THEN 'Nicht definiert'
        ELSE COALESCE(op.payment_type, 'Unbekannt')
    END AS zahlungsart,
    op.payment_sequential   AS zahlungsnummer,
    op.payment_installments AS ratenanzahl,
    op.payment_value        AS betrag
FROM olist.order_payments op;


/* ============================================================
   11. CATEGORY DISPLAY VIEW
   ============================================================ */

DROP VIEW IF EXISTS olist.v_kategorien_anzeigename;

CREATE OR REPLACE VIEW olist.v_kategorien_anzeigename AS
SELECT
    p.product_id,
    p.product_category_name AS kategorie_portugiesisch,
    ct.product_category_name_english AS kategorie_englisch,
    de.category_de AS kategorie_deutsch,
    COALESCE(
        de.category_de,
        ct.product_category_name_english,
        p.product_category_name,
        'unbekannt'
    ) AS kategorie_anzeige
FROM olist.products p
LEFT JOIN olist.category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN olist.category_translation_de de
    ON ct.product_category_name_english = de.category_en;


/* ============================================================
   12. BASE ANALYSIS VIEW
   ============================================================ */

DROP VIEW IF EXISTS olist.v_bestellungen;

CREATE OR REPLACE VIEW olist.v_bestellungen AS
SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_delivered_customer_date,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS positionsumsatz
FROM olist.orders o
JOIN olist.customers c
    ON o.customer_id = c.customer_id
JOIN olist.order_items oi
    ON o.order_id = oi.order_id;


/* ============================================================
   13. ANALYSES
   ============================================================ */

-- 13.1 Top cities by orders
SELECT
    customer_city,
    COUNT(DISTINCT order_id) AS bestellungen
FROM olist.v_bestellungen
GROUP BY customer_city
ORDER BY bestellungen DESC, customer_city
LIMIT 10;

-- 13.2 Total revenue
SELECT
    ROUND(SUM(price + freight_value), 2) AS gesamtumsatz
FROM olist.order_items;

-- 13.3 Average review score
SELECT
    ROUND(AVG(review_score)::NUMERIC, 2) AS durchschnittliche_bewertung
FROM olist.order_reviews;

-- 13.4 Orders per month
SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS monat,
    COUNT(*) AS anzahl_bestellungen
FROM olist.orders
GROUP BY DATE_TRUNC('month', order_purchase_timestamp)
ORDER BY monat;

-- 13.5 Revenue per month
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp) AS monat,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS umsatz
FROM olist.orders o
JOIN olist.order_items oi
    ON o.order_id = oi.order_id
GROUP BY DATE_TRUNC('month', o.order_purchase_timestamp)
ORDER BY monat;

-- 13.6 Average delivery time in days
SELECT
    ROUND(
        AVG(
            EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400
        )::NUMERIC,
        2
    ) AS durchschnittliche_lieferzeit_tage
FROM olist.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp;

-- 13.7 Delivery time per order
SELECT
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    ROUND(
        (
            EXTRACT(EPOCH FROM (order_delivered_customer_date - order_purchase_timestamp)) / 86400
        )::NUMERIC,
        2
    ) AS lieferdauer_tage
FROM olist.orders
WHERE order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp IS NOT NULL
  AND order_delivered_customer_date >= order_purchase_timestamp
ORDER BY lieferdauer_tage DESC;

-- 13.8 Orders with multiple products
SELECT
    order_id,
    COUNT(*) AS anzahl_produkte
FROM olist.order_items
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY anzahl_produkte DESC, order_id;

-- 13.9 Customers with most orders
SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS anzahl_bestellungen
FROM olist.orders o
JOIN olist.customers c
    ON o.customer_id = c.customer_id
GROUP BY c.customer_unique_id
ORDER BY anzahl_bestellungen DESC, c.customer_unique_id
LIMIT 10;

-- 13.10 Revenue by payment type
SELECT
    CASE
        WHEN payment_type = 'credit_card' THEN 'Kreditkarte'
        WHEN payment_type = 'debit_card'  THEN 'Debitkarte'
        WHEN payment_type = 'voucher'     THEN 'Gutschein'
        WHEN payment_type = 'boleto'      THEN 'Boleto'
        WHEN payment_type = 'not_defined' THEN 'Nicht definiert'
        ELSE COALESCE(payment_type, 'Unbekannt')
    END AS zahlungsart,
    ROUND(SUM(payment_value), 2) AS umsatz
FROM olist.order_payments
GROUP BY 1
ORDER BY umsatz DESC;

-- 13.11 Average review score by product category
SELECT
    COALESCE(
        de.category_de,
        ct.product_category_name_english,
        p.product_category_name,
        'unbekannt'
    ) AS kategorie,
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS durchschnittsbewertung,
    COUNT(DISTINCT r.order_id) AS anzahl_bewertungen
FROM olist.order_reviews r
JOIN olist.orders o
    ON r.order_id = o.order_id
JOIN olist.order_items oi
    ON o.order_id = oi.order_id
JOIN olist.products p
    ON oi.product_id = p.product_id
LEFT JOIN olist.category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN olist.category_translation_de de
    ON ct.product_category_name_english = de.category_en
WHERE r.review_score IS NOT NULL
GROUP BY COALESCE(
    de.category_de,
    ct.product_category_name_english,
    p.product_category_name,
    'unbekannt'
)
ORDER BY durchschnittsbewertung ASC, anzahl_bewertungen DESC;

-- 13.12 Worst categories by review score
SELECT
    COALESCE(
        de.category_de,
        ct.product_category_name_english,
        p.product_category_name,
        'unbekannt'
    ) AS kategorie,
    ROUND(AVG(r.review_score)::NUMERIC, 2) AS durchschnittsbewertung,
    COUNT(DISTINCT r.order_id) AS anzahl_bewertungen
FROM olist.order_reviews r
JOIN olist.order_items oi
    ON r.order_id = oi.order_id
JOIN olist.products p
    ON oi.product_id = p.product_id
LEFT JOIN olist.category_translation ct
    ON p.product_category_name = ct.product_category_name
LEFT JOIN olist.category_translation_de de
    ON ct.product_category_name_english = de.category_en
WHERE r.review_score IS NOT NULL
GROUP BY COALESCE(
    de.category_de,
    ct.product_category_name_english,
    p.product_category_name,
    'unbekannt'
)
HAVING COUNT(DISTINCT r.order_id) >= 30
ORDER BY durchschnittsbewertung ASC, anzahl_bewertungen DESC
LIMIT 10;

-- 13.13 Average basket value
SELECT
    ROUND(AVG(bestellwert)::NUMERIC, 2) AS durchschnittlicher_warenkorbwert
FROM (
    SELECT
        order_id,
        SUM(price + freight_value) AS bestellwert
    FROM olist.order_items
    GROUP BY order_id
) x;

-- 13.14 Average products per order
SELECT
    ROUND(AVG(anzahl_produkte)::NUMERIC, 2) AS durchschnittliche_produkte_pro_bestellung
FROM (
    SELECT
        order_id,
        COUNT(*) AS anzahl_produkte
    FROM olist.order_items
    GROUP BY order_id
) x;

-- 13.15 Review score distribution
SELECT
    review_score,
    COUNT(*) AS anzahl
FROM olist.order_reviews
GROUP BY review_score
ORDER BY review_score;

-- 13.16 Top sellers by revenue
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS umsatz
FROM olist.order_items oi
GROUP BY oi.seller_id
ORDER BY umsatz DESC
LIMIT 10;

-- 13.17 Orders by weekday
SELECT
    TO_CHAR(order_purchase_timestamp, 'Day') AS wochentag,
    COUNT(*) AS anzahl_bestellungen
FROM olist.orders
GROUP BY TO_CHAR(order_purchase_timestamp, 'Day')
ORDER BY anzahl_bestellungen DESC;

-- 13.18 Order status distribution
SELECT
    order_status,
    COUNT(*) AS anzahl
FROM olist.orders
GROUP BY order_status
ORDER BY anzahl DESC;


/* ============================================================
   14. WINDOW FUNCTIONS AND CUSTOMER ANALYSIS
   ============================================================ */

-- 14.1 Seller ranking by revenue
SELECT
    seller_id,
    umsatz,
    RANK() OVER (ORDER BY umsatz DESC) AS umsatz_rang
FROM (
    SELECT
        seller_id,
        ROUND(SUM(price + freight_value), 2) AS umsatz
    FROM olist.order_items
    GROUP BY seller_id
) s
ORDER BY umsatz_rang;

-- 14.2 Repeat buyer analysis
SELECT
    customer_unique_id,
    anzahl_bestellungen,
    CASE
        WHEN anzahl_bestellungen = 1 THEN 'Einmalkäufer'
        ELSE 'Wiederkäufer'
    END AS kundentyp
FROM (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS anzahl_bestellungen
    FROM olist.orders o
    JOIN olist.customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_unique_id
) t
ORDER BY anzahl_bestellungen DESC;

-- 14.3 Customer lifetime value
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS clv
FROM olist.orders o
JOIN olist.customers c
    ON o.customer_id = c.customer_id
JOIN olist.order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY clv DESC
LIMIT 20;


/* ============================================================
   15. CRITICAL CATEGORIES
   High revenue, weak review scores
   ============================================================ */

SELECT
    kategorie,
    umsatz,
    durchschnittsbewertung,
    anzahl_bewertungen
FROM (
    SELECT
        COALESCE(
            de.category_de,
            ct.product_category_name_english,
            p.product_category_name,
            'unbekannt'
        ) AS kategorie,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS umsatz,
        ROUND(AVG(r.review_score)::NUMERIC, 2) AS durchschnittsbewertung,
        COUNT(DISTINCT r.order_id) AS anzahl_bewertungen
    FROM olist.order_items oi
    JOIN olist.products p
        ON oi.product_id = p.product_id
    LEFT JOIN olist.category_translation ct
        ON p.product_category_name = ct.product_category_name
    LEFT JOIN olist.category_translation_de de
        ON ct.product_category_name_english = de.category_en
    LEFT JOIN olist.order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY COALESCE(
        de.category_de,
        ct.product_category_name_english,
        p.product_category_name,
        'unbekannt'
    )
) x
WHERE anzahl_bewertungen >= 30
ORDER BY umsatz DESC, durchschnittsbewertung ASC;
