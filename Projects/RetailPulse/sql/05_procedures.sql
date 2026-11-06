-- RetailPulse | A transaction that reserves one product for a pending order.
-- Call only outside an existing transaction: this procedure owns COMMIT/ROLLBACK.
-- This is a database reservation demo, not a payment processor. A production
-- checkout also needs request idempotency, reservation expiry/release, and a
-- verified payment callback before changing the order to a recognized status.
USE retailpulse;

DELIMITER $$
CREATE PROCEDURE sp_place_order(
    IN p_customer_id BIGINT UNSIGNED,
    IN p_product_id BIGINT UNSIGNED,
    IN p_quantity INT,
    IN p_channel VARCHAR(20),
    OUT p_order_id BIGINT UNSIGNED
)
SQL SECURITY INVOKER
BEGIN
    DECLARE v_price DECIMAL(12, 2);
    DECLARE v_cost DECIMAL(12, 2);
    DECLARE v_stock INT;
    DECLARE v_customer_count INT;
    DECLARE v_missing BOOLEAN DEFAULT FALSE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_missing = TRUE;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_order_id = NULL;
        RESIGNAL;
    END;

    SET p_order_id = NULL;
    IF p_quantity IS NULL OR p_quantity < 1 OR p_quantity > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be between 1 and 100';
    END IF;
    IF p_channel IS NULL OR p_channel NOT IN ('web', 'mobile', 'marketplace') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unsupported sales channel';
    END IF;
    IF p_customer_id IS NULL OR p_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer and product are required';
    END IF;

    START TRANSACTION;
    SELECT COUNT(*) INTO v_customer_count
    FROM customers WHERE customer_id = p_customer_id;
    IF v_customer_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Customer does not exist';
    END IF;

    -- The row lock serializes reservations for this product. Another session
    -- must wait and then observes the updated stock before placing its order.
    SELECT unit_price, unit_cost, stock_quantity
      INTO v_price, v_cost, v_stock
    FROM products WHERE product_id = p_product_id FOR UPDATE;
    IF v_missing THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product does not exist';
    END IF;
    IF v_stock < p_quantity THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock';
    END IF;

    INSERT INTO orders (customer_id, ordered_at, status, channel)
    VALUES (p_customer_id, UTC_TIMESTAMP(), 'pending', p_channel);
    SET p_order_id = LAST_INSERT_ID();
    INSERT INTO order_items
        (order_id, product_id, quantity, unit_price, unit_cost, discount_amount)
    VALUES (p_order_id, p_product_id, p_quantity, v_price, v_cost, 0.00);
    UPDATE products SET stock_quantity = stock_quantity - p_quantity
    WHERE product_id = p_product_id;
    INSERT INTO inventory_movements
        (product_id, order_id, quantity_delta, reason, created_at)
    VALUES (p_product_id, p_order_id, -p_quantity, 'reservation', UTC_TIMESTAMP());
    COMMIT;
END$$
DELIMITER ;

-- Example (creates a real pending order; deliberately not run automatically):
-- CALL sp_place_order(1, 1, 2, 'web', @new_order_id);
-- SELECT @new_order_id;
