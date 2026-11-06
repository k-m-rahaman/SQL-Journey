-- RetailPulse | executable acceptance tests for the supplied demo fixture.
-- mysql must run without --force: any failed assertion exits with an error.
-- Run after 01, 02, 03 and 05. Successful tests remove their own test records.
USE retailpulse;

DELIMITER $$
-- Fault injection is limited to this session and reset before test cleanup.
CREATE TRIGGER retailpulse_test_reject_movement
BEFORE INSERT ON inventory_movements FOR EACH ROW
BEGIN
    IF COALESCE(@retailpulse_test_fail_ledger, 0) = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Injected ledger failure';
    END IF;
END$$

CREATE PROCEDURE retailpulse_assert(IN p_condition BOOLEAN, IN p_message VARCHAR(128))
BEGIN
    IF p_condition IS NULL OR NOT p_condition THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = p_message;
    END IF;
END$$

CREATE PROCEDURE retailpulse_run_tests()
BEGIN
    DECLARE v_customer BIGINT UNSIGNED;
    DECLARE v_product BIGINT UNSIGNED;
    DECLARE v_order BIGINT UNSIGNED;
    DECLARE v_count BIGINT;
    DECLARE v_total DECIMAL(18, 2);
    DECLARE v_expected DECIMAL(18, 2);
    DECLARE v_rejected BOOLEAN DEFAULT FALSE;

    -- Dataset coverage and empty-period edge case.
    CALL retailpulse_assert((SELECT COUNT(*) FROM customers) = 600, 'Fixture: expected 600 customers');
    CALL retailpulse_assert((SELECT COUNT(*) FROM products) = 24, 'Fixture: expected 24 products');
    CALL retailpulse_assert((SELECT COUNT(*) FROM orders) = 3600, 'Fixture: expected 3600 orders');
    CALL retailpulse_assert((SELECT COUNT(*) FROM order_items) = 7200, 'Fixture: expected 7200 items');
    CALL retailpulse_assert((SELECT COUNT(*) FROM payments) = 3640, 'Fixture: expected 3640 payment attempts');
    CALL retailpulse_assert((SELECT COUNT(*) FROM refunds) = 378, 'Fixture: expected 378 partial refunds');
    CALL retailpulse_assert((SELECT COUNT(*) FROM orders WHERE ordered_at >= '2025-06-01'
                            AND ordered_at < '2025-07-01') = 0, 'Fixture: June must be empty');
    CALL retailpulse_assert((SELECT COUNT(*) FROM customers AS c WHERE NOT EXISTS
                            (SELECT 1 FROM orders AS o WHERE o.customer_id = c.customer_id)) = 20,
                           'Fixture: expected 20 never-ordering customers');

    -- Grain, financial reconciliation, and independently calculated control total.
    CALL retailpulse_assert((SELECT COUNT(*) FROM v_order_financials) = 3600, 'Order view changed row grain');
    CALL retailpulse_assert((SELECT COUNT(DISTINCT order_id) FROM v_order_financials) = 3600,
                           'Order view contains duplicate orders');
    SELECT SUM(oi.quantity * oi.unit_price - oi.discount_amount) INTO v_expected
    FROM order_items AS oi JOIN orders AS o ON o.order_id = oi.order_id
    WHERE o.status IN ('paid', 'shipped', 'completed');
    SELECT v_expected - SUM(r.amount) INTO v_expected
    FROM refunds AS r JOIN orders AS o ON o.order_id = r.order_id
    WHERE o.status IN ('paid', 'shipped', 'completed');
    SELECT SUM(net_revenue) INTO v_total FROM v_order_financials;
    CALL retailpulse_assert(v_total = v_expected, 'Revenue disagrees with independent base-table total');
    CALL retailpulse_assert((SELECT COUNT(*) FROM v_order_financials
                             WHERE status IN ('paid', 'shipped', 'completed')
                               AND captured_amount <> net_sales) = 0, 'Captured payments do not reconcile');
    CALL retailpulse_assert((SELECT COUNT(*) FROM v_order_financials
                             WHERE refund_amount > captured_amount) = 0, 'Refund exceeds captured payment');
    CALL retailpulse_assert((SELECT COUNT(*) FROM v_order_financials
                             WHERE status IN ('pending', 'cancelled') AND net_revenue <> 0) = 0,
                           'Non-sales leaked into revenue');
    CALL retailpulse_assert((SELECT COUNT(*) FROM v_customer_metrics) = 600, 'Customer view lost nonbuyers');
    CALL retailpulse_assert((SELECT SUM(total_net_revenue) FROM v_customer_metrics) = v_total,
                           'Customer revenue does not reconcile');
    CALL retailpulse_assert((SELECT SUM(net_revenue) FROM v_monthly_sales) = v_total,
                           'Monthly revenue does not reconcile');
    CALL retailpulse_assert((SELECT COUNT(*) FROM payments AS p JOIN orders AS o ON o.order_id = p.order_id
                             WHERE p.paid_at < o.ordered_at) = 0, 'Payment predates order');
    CALL retailpulse_assert((SELECT COUNT(*) FROM refunds AS r JOIN orders AS o ON o.order_id = r.order_id
                             WHERE r.refunded_at < o.ordered_at) = 0, 'Refund predates order');
    CALL retailpulse_assert((SELECT COUNT(*) FROM orders AS o JOIN customers AS c ON c.customer_id = o.customer_id
                             WHERE DATE(o.ordered_at) < c.signup_date) = 0, 'Order predates signup');
    CALL retailpulse_assert((SELECT COUNT(*) FROM products AS p WHERE p.stock_quantity <>
                             COALESCE((SELECT SUM(m.quantity_delta) FROM inventory_movements AS m
                              WHERE m.product_id = p.product_id), 0)) = 0, 'Inventory ledger does not reconcile');
    CALL retailpulse_assert(EXISTS(SELECT 1 FROM payments GROUP BY order_id HAVING COUNT(*) > 1),
                           'Fixture lacks multiple payment attempts');
    CALL retailpulse_assert(EXISTS(SELECT 1 FROM refunds GROUP BY order_id HAVING COUNT(*) > 1),
                           'Fixture lacks multiple partial refunds');

    -- Disposable records isolate mutation tests from the business fixture.
    INSERT INTO customers (full_name, email, city, signup_date)
    VALUES ('Acceptance Test', CONCAT('test-', UUID(), '@example.com'), 'Test City', UTC_DATE());
    SET v_customer = LAST_INSERT_ID();
    INSERT INTO products (category_id, sku, name, unit_price, unit_cost, stock_quantity)
    VALUES (1, CONCAT('T-', UUID()), 'Acceptance Test Product', 10.00, 4.00, 5);
    SET v_product = LAST_INSERT_ID();
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR 3819 SET v_rejected = TRUE;
        UPDATE products SET stock_quantity = -1 WHERE product_id = v_product;
    END;
    CALL retailpulse_assert(v_rejected, 'CHECK failed to reject negative stock');
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR 1062 SET v_rejected = TRUE;
        INSERT INTO customers (full_name, email, city, signup_date)
        SELECT full_name, email, city, signup_date FROM customers WHERE customer_id = v_customer;
    END;
    CALL retailpulse_assert(v_rejected, 'UNIQUE failed to reject duplicate email');
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR 1452 SET v_rejected = TRUE;
        INSERT INTO orders (customer_id, ordered_at, status, channel)
        VALUES (0, UTC_TIMESTAMP(), 'pending', 'web');
    END;
    CALL retailpulse_assert(v_rejected, 'FK failed to reject missing customer');

    CALL sp_place_order(v_customer, v_product, 2, 'web', v_order);
    CALL retailpulse_assert(v_order IS NOT NULL, 'Reservation returned no order ID');
    CALL retailpulse_assert((SELECT stock_quantity FROM products WHERE product_id = v_product) = 3,
                           'Reservation did not decrement stock');
    CALL retailpulse_assert((SELECT status FROM orders WHERE order_id = v_order) = 'pending',
                           'Reservation must remain pending');
    CALL retailpulse_assert((SELECT COUNT(*) FROM payments WHERE order_id = v_order) = 0,
                           'Reservation fabricated a payment');
    CALL retailpulse_assert((SELECT net_revenue FROM v_order_financials WHERE order_id = v_order) = 0,
                           'Pending reservation recognized revenue');
    CALL retailpulse_assert((SELECT quantity_delta FROM inventory_movements WHERE order_id = v_order) = -2,
                           'Reservation ledger is incorrect');
    UPDATE products SET unit_price = 99.00 WHERE product_id = v_product;
    CALL retailpulse_assert((SELECT unit_price FROM order_items WHERE order_id = v_order) = 10.00,
                           'Historical item price changed with catalogue');

    SELECT COUNT(*) INTO v_count FROM orders;
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET v_rejected = TRUE;
        CALL sp_place_order(v_customer, v_product, 4, 'web', @rejected_order);
    END;
    CALL retailpulse_assert(v_rejected, 'Overselling was accepted');
    CALL retailpulse_assert((SELECT COUNT(*) FROM orders) = v_count, 'Rejected reservation left an order');
    CALL retailpulse_assert((SELECT stock_quantity FROM products WHERE product_id = v_product) = 3,
                           'Rejected reservation changed stock');
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET v_rejected = TRUE;
        CALL sp_place_order(v_customer, v_product, 0, 'web', @rejected_order);
    END;
    CALL retailpulse_assert(v_rejected, 'Zero quantity was accepted');
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET v_rejected = TRUE;
        CALL sp_place_order(v_customer, 0, 1, 'web', @rejected_order);
    END;
    CALL retailpulse_assert(v_rejected, 'Missing product was accepted');
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET v_rejected = TRUE;
        CALL sp_place_order(v_customer, v_product, 1, 'invalid', @rejected_order);
    END;
    CALL retailpulse_assert(v_rejected, 'Invalid channel was accepted');

    -- Fail AFTER order/item inserts and the stock UPDATE. The procedure's
    -- exception handler must undo all earlier writes, not merely reject input.
    SET @retailpulse_test_fail_ledger = 1;
    SET v_rejected = FALSE;
    BEGIN
        DECLARE CONTINUE HANDLER FOR SQLSTATE '45000' SET v_rejected = TRUE;
        CALL sp_place_order(v_customer, v_product, 1, 'web', @rejected_order);
    END;
    SET @retailpulse_test_fail_ledger = NULL;
    CALL retailpulse_assert(v_rejected, 'Injected late failure did not occur');
    CALL retailpulse_assert((SELECT COUNT(*) FROM orders) = v_count, 'Rollback left an orphan order');
    CALL retailpulse_assert((SELECT COUNT(*) FROM order_items WHERE product_id = v_product) = 1,
                           'Rollback left an orphan item');
    CALL retailpulse_assert((SELECT stock_quantity FROM products WHERE product_id = v_product) = 3,
                           'Late failure did not restore stock');

    START TRANSACTION;
    DELETE FROM inventory_movements WHERE product_id = v_product;
    DELETE FROM order_items WHERE order_id = v_order;
    DELETE FROM orders WHERE order_id = v_order;
    DELETE FROM products WHERE product_id = v_product;
    DELETE FROM customers WHERE customer_id = v_customer;
    COMMIT;
    SELECT 'PASS: fixture, financial controls, constraints, reservation and rollback' AS test_result,
           v_total AS verified_net_revenue;
END$$
DELIMITER ;

CALL retailpulse_run_tests();
DROP TRIGGER retailpulse_test_reject_movement;
DROP PROCEDURE retailpulse_run_tests;
DROP PROCEDURE retailpulse_assert;
