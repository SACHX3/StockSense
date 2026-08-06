-- ============================================================
-- SEED FORECAST DEMO DATA
-- Run this in phpMyAdmin on smart_inventory_db (SQL tab)
--
-- Why: AI Demand Forecasting trains on each product's real daily
-- sales. The original demo data only ever created 8 sample sales
-- touching a handful of products, so most products had ZERO sales
-- history and correctly forecast 0 demand - which looks "broken"
-- but is actually accurate given no real data. This script backfills
-- ~90 days of realistic sales for every active product that doesn't
-- already have recent history, so forecasting has something real to
-- learn from across your whole catalog.
--
-- Safe to run once. It only fills in products with no sales in the
-- last 90 days, so it won't duplicate or disturb real sales you've
-- already recorded, and it does NOT touch products.quantity (your
-- current stock levels are left alone).
-- ============================================================

USE smart_inventory_db;

DELIMITER $$

DROP PROCEDURE IF EXISTS seed_forecast_demo_data $$
CREATE PROCEDURE seed_forecast_demo_data()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_product_id BIGINT;
    DECLARE v_sell_price DECIMAL(12,2);
    DECLARE v_day INT;
    DECLARE v_qty INT;
    DECLARE v_admin_id BIGINT;
    DECLARE v_sale_id BIGINT;
    DECLARE v_invoice VARCHAR(100);
    DECLARE v_created TIMESTAMP;
    DECLARE v_dow INT;

    DECLARE prod_cursor CURSOR FOR
        SELECT id, selling_price FROM products WHERE is_active = TRUE;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SELECT id INTO v_admin_id FROM users WHERE username = 'admin' LIMIT 1;

    OPEN prod_cursor;
    read_loop: LOOP
        FETCH prod_cursor INTO v_product_id, v_sell_price;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Skip products that already have real sales in the last 90 days
        IF NOT EXISTS (
            SELECT 1 FROM sales_items si
            JOIN sales s ON si.sale_id = s.id
            WHERE si.product_id = v_product_id AND s.created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)
        ) THEN
            SET v_day = 90;
            WHILE v_day >= 1 DO
                SET v_created = DATE_SUB(NOW(), INTERVAL v_day DAY);
                SET v_dow = DAYOFWEEK(v_created); -- 1=Sun, 7=Sat

                -- ~55-80% of days get a sale; weekends sell a bit more/heavier
                IF RAND() < IF(v_dow IN (1,7), 0.8, 0.55) THEN
                    SET v_qty = FLOOR(1 + RAND() * IF(v_dow IN (1,7), 8, 5));
                    SET v_invoice = CONCAT('INV-DEMO90-', v_product_id, '-', v_day);

                    INSERT INTO sales (invoice_number, user_id, customer_name, subtotal, total_amount,
                                        payment_method, payment_status, created_at, updated_at)
                    VALUES (v_invoice, v_admin_id, 'Walk-in Customer',
                            v_sell_price * v_qty, v_sell_price * v_qty,
                            'CASH', 'PAID', v_created, v_created);

                    SET v_sale_id = LAST_INSERT_ID();

                    INSERT INTO sales_items (sale_id, product_id, quantity, unit_price, discount_percent, total_price)
                    VALUES (v_sale_id, v_product_id, v_qty, v_sell_price, 0, v_sell_price * v_qty);
                END IF;

                SET v_day = v_day - 1;
            END WHILE;
        END IF;
    END LOOP;
    CLOSE prod_cursor;
END $$

DELIMITER ;

CALL seed_forecast_demo_data();
DROP PROCEDURE seed_forecast_demo_data;

-- Verify: shows how many days had sales + total units sold per product
-- over the last 90 days. Every active product should now show > 0.
SELECT p.name,
       COALESCE(x.days_with_sales, 0) AS days_with_sales,
       COALESCE(x.total_units_90d, 0) AS total_units_90d
FROM products p
LEFT JOIN (
    SELECT si.product_id,
           COUNT(DISTINCT DATE(s.created_at)) AS days_with_sales,
           SUM(si.quantity) AS total_units_90d
    FROM sales_items si
    JOIN sales s ON si.sale_id = s.id
    WHERE s.created_at >= DATE_SUB(NOW(), INTERVAL 90 DAY)
    GROUP BY si.product_id
) x ON x.product_id = p.id
WHERE p.is_active = TRUE
ORDER BY p.name;
