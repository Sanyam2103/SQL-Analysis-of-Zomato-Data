-- =============================================
-- 7. Advanced Analytics Queries (advanced_analytics.sql)
-- =============================================
USE zomato_analytics;

-- Customer Lifetime Value (CLV)
WITH customer_metrics AS (
    SELECT 
        o.customer_id,
        COUNT(*) AS total_orders,
        SUM(o.order_value) AS total_spent,
        ROUND(AVG(o.order_value), 2) AS avg_order_value,
        DATEDIFF(MAX(o.order_datetime), MIN(o.order_datetime)) + 1 AS lifespan_days
    FROM orders o
    WHERE o.order_status = 'Delivered'
    GROUP BY o.customer_id
)
SELECT 
    customer_id,
    total_orders,
    total_spent,
    avg_order_value,
    lifespan_days,
    ROUND(avg_order_value * total_orders, 2) AS simple_clv,
    ROUND(avg_order_value * total_orders * (365.0 / lifespan_days), 2) AS adjusted_clv
FROM customer_metrics
ORDER BY adjusted_clv DESC
LIMIT 20;

-- Market Basket Analysis (Simple)
WITH item_pairs AS (
    SELECT 
        oi1.item_id AS item_a,
        oi2.item_id AS item_b,
        COUNT(*) AS co_occur_count
    FROM order_items oi1
    JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.item_id < oi2.item_id
    GROUP BY oi1.item_id, oi2.item_id
    HAVING co_occur_count >= 5
)
SELECT * FROM item_pairs
ORDER BY co_occur_count DESC
LIMIT 20;

-- Demand Features Prep
SELECT 
    DATE(order_datetime) AS order_date,
    DAYOFWEEK(order_datetime) AS day_of_week,
    r.restaurant_category,
    mi.item_category,
    COUNT(*) AS order_count,
    AVG(order_value) AS avg_value,
    AVG(delivery_time_minutes) AS avg_delivery
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN menu_items mi ON oi.item_id = mi.item_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY order_date, day_of_week, r.restaurant_category, mi.item_category
ORDER BY order_date DESC;
