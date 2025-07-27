-- =============================================
-- 5. Dynamic Pricing Procedures (dynamic_pricing.sql)
-- =============================================
USE zomato_analytics;

-- Drop if exists
DROP FUNCTION IF EXISTS GetDemandScore;
DROP FUNCTION IF EXISTS GetCompetitionFactor;
DROP PROCEDURE IF EXISTS CalculateDynamicPricing;

DELIMITER //

-- Function: GetDemandScore
CREATE FUNCTION GetDemandScore(p_item_id INT) RETURNS DECIMAL(3,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_score DECIMAL(3,2);
    DECLARE v_item_orders INT;
    DECLARE v_max_orders INT;

    SELECT COUNT(*) INTO v_item_orders
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    WHERE oi.item_id = p_item_id AND o.order_datetime >= DATE_SUB(NOW(), INTERVAL 24 HOUR);

    SELECT MAX(cnt) INTO v_max_orders
    FROM (
        SELECT COUNT(*) AS cnt
        FROM order_items oi
        JOIN orders o ON oi.order_id = o.order_id
        WHERE o.order_datetime >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
        GROUP BY oi.item_id
    ) x;

    IF v_max_orders > 0 THEN
        SET v_score = LEAST(1.0, v_item_orders / v_max_orders);
    ELSE
        SET v_score = 0.5;
    END IF;

    RETURN v_score;
END //

-- Procedure: CalculateDynamicPricing
CREATE PROCEDURE CalculateDynamicPricing(IN p_restaurant_id INT, IN p_target_margin DECIMAL(5,2))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_item_id INT;
    DECLARE v_base_price DECIMAL(8,2);
    DECLARE v_demand DECIMAL(3,2);
    DECLARE v_price DECIMAL(8,2);
    DECLARE item_cursor CURSOR FOR
        SELECT item_id, base_price FROM menu_items WHERE restaurant_id = p_restaurant_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    CREATE TEMPORARY TABLE IF NOT EXISTS recommended_prices (
        item_id INT, new_price DECIMAL(8,2)
    );

    OPEN item_cursor;
    pricing_loop: LOOP
        FETCH item_cursor INTO v_item_id, v_base_price;
        IF done THEN
            LEAVE pricing_loop;
        END IF;

        SET v_demand = GetDemandScore(v_item_id);
        SET v_price = v_base_price * (1 + (v_demand - 0.5) * 0.2);
        SET v_price = ROUND(v_price, 2);

        INSERT INTO recommended_prices VALUES (v_item_id, v_price);
    END LOOP;
    CLOSE item_cursor;

    SELECT * FROM recommended_prices;
END //

DELIMITER ;

SELECT 'Dynamic pricing procedures created successfully!' AS Status;
