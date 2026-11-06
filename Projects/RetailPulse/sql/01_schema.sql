-- RetailPulse | MySQL 8.0.18+ (CHECK constraints require 8.0.16 or later).
-- Run against a new project database. Existing tables cause an error by design.
-- No DROP or TRUNCATE commands: an accidental rerun does not erase your work.
CREATE DATABASE IF NOT EXISTS retailpulse
    CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE retailpulse;

CREATE TABLE customers (
    customer_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(190) NOT NULL,
    city VARCHAR(80) NOT NULL,
    signup_date DATE NOT NULL,
    PRIMARY KEY (customer_id),
    CONSTRAINT uq_customers_email UNIQUE (email),
    CONSTRAINT ck_customers_name CHECK (CHAR_LENGTH(TRIM(full_name)) > 0),
    CONSTRAINT ck_customers_email CHECK (CHAR_LENGTH(TRIM(email)) > 0),
    CONSTRAINT ck_customers_city CHECK (CHAR_LENGTH(TRIM(city)) > 0)
) ENGINE = InnoDB;

CREATE TABLE categories (
    category_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(80) NOT NULL,
    PRIMARY KEY (category_id),
    CONSTRAINT uq_categories_name UNIQUE (name),
    CONSTRAINT ck_categories_name CHECK (CHAR_LENGTH(TRIM(name)) > 0)
) ENGINE = InnoDB;

CREATE TABLE products (
    product_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    category_id BIGINT UNSIGNED NOT NULL,
    sku VARCHAR(40) NOT NULL,
    name VARCHAR(120) NOT NULL,
    unit_price DECIMAL(12, 2) NOT NULL,
    unit_cost DECIMAL(12, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT uq_products_sku UNIQUE (sku),
    CONSTRAINT fk_products_category FOREIGN KEY (category_id)
        REFERENCES categories (category_id),
    CONSTRAINT ck_products_sku CHECK (CHAR_LENGTH(TRIM(sku)) > 0),
    CONSTRAINT ck_products_name CHECK (CHAR_LENGTH(TRIM(name)) > 0),
    CONSTRAINT ck_products_price CHECK (unit_price > 0),
    CONSTRAINT ck_products_cost CHECK (unit_cost >= 0),
    CONSTRAINT ck_products_stock CHECK (stock_quantity >= 0)
) ENGINE = InnoDB;

CREATE TABLE orders (
    order_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    customer_id BIGINT UNSIGNED NOT NULL,
    ordered_at DATETIME NOT NULL,
    status ENUM('pending', 'paid', 'shipped', 'completed', 'cancelled') NOT NULL,
    channel ENUM('web', 'mobile', 'marketplace') NOT NULL,
    PRIMARY KEY (order_id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (customer_id),
    INDEX idx_orders_customer_date (customer_id, ordered_at),
    INDEX idx_orders_status_date (status, ordered_at, customer_id),
    INDEX idx_orders_date (ordered_at)
) ENGINE = InnoDB;

CREATE TABLE order_items (
    order_id BIGINT UNSIGNED NOT NULL,
    product_id BIGINT UNSIGNED NOT NULL,
    quantity INT NOT NULL,
    -- Historical snapshots: later catalogue changes must not rewrite margin.
    unit_price DECIMAL(12, 2) NOT NULL,
    unit_cost DECIMAL(12, 2) NOT NULL,
    -- Total discount for this entire line, not a discount per unit.
    discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    PRIMARY KEY (order_id, product_id),
    CONSTRAINT fk_items_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
    CONSTRAINT fk_items_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT ck_items_quantity CHECK (quantity > 0),
    CONSTRAINT ck_items_price CHECK (unit_price > 0),
    CONSTRAINT ck_items_cost CHECK (unit_cost >= 0),
    CONSTRAINT ck_items_discount CHECK (
        discount_amount >= 0 AND discount_amount <= quantity * unit_price
    ),
    INDEX idx_items_product_order (product_id, order_id)
) ENGINE = InnoDB;

CREATE TABLE payments (
    payment_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    status ENUM('captured', 'failed') NOT NULL,
    paid_at DATETIME NOT NULL,
    PRIMARY KEY (payment_id),
    CONSTRAINT fk_payments_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
    CONSTRAINT ck_payments_amount CHECK (amount > 0),
    INDEX idx_payments_order_status (order_id, status)
) ENGINE = InnoDB;

CREATE TABLE refunds (
    refund_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    order_id BIGINT UNSIGNED NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    refunded_at DATETIME NOT NULL,
    reason VARCHAR(160) NOT NULL,
    PRIMARY KEY (refund_id),
    CONSTRAINT fk_refunds_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
    CONSTRAINT ck_refunds_amount CHECK (amount > 0),
    CONSTRAINT ck_refunds_reason CHECK (CHAR_LENGTH(TRIM(reason)) > 0),
    INDEX idx_refunds_order_date (order_id, refunded_at)
) ENGINE = InnoDB;

CREATE TABLE inventory_movements (
    movement_id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    product_id BIGINT UNSIGNED NOT NULL,
    order_id BIGINT UNSIGNED NULL,
    quantity_delta INT NOT NULL,
    reason VARCHAR(100) NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (movement_id),
    CONSTRAINT fk_movements_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_movements_order FOREIGN KEY (order_id) REFERENCES orders (order_id),
    CONSTRAINT ck_movements_nonzero CHECK (quantity_delta <> 0),
    CONSTRAINT ck_movements_reason CHECK (CHAR_LENGTH(TRIM(reason)) > 0),
    INDEX idx_movements_product_date (product_id, created_at),
    INDEX idx_movements_order (order_id)
) ENGINE = InnoDB;

-- Cross-table rules (payment reconciliation, refund limits, chronology) are
-- verified in 06_tests.sql. InnoDB CHECK constraints cannot query other tables.
