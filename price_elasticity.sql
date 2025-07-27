-- =============================================
-- 4. Price Elasticity Analysis (price_elasticity.sql)
-- =============================================
USE zomato_analytics;

-- Price Change Impact Analysis
WITH price_changes AS (
    SELECT 
        mi.item_id,
        mi.restaurant_id,
        mi.item_name,
        mi.item_category,
        r.restaurant_category,
        mi.base_price,
        mi.current_price,
        ROUND((mi.current_price - mi.base_price) / mi.base_price * 100, 2) as price_change_percent,
        mi.last_price_update
    FROM menu_items mi
    JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
    WHERE mi.current_price != mi.base_price
),
demand_analysis AS (
    SELECT 
        pc.item_id,
        pc.restaurant_id,
        pc.item_category,
        pc.restaurant_category,
        pc.price_change_percent,
        pc.base_price,
        pc.current_price,
        COUNT(CASE WHEN o.order_datetime < pc.last_price_update THEN 1 END) as orders_before,
        COUNT(CASE WHEN o.order_datetime >= pc.last_price_update THEN 1 END) as orders_after
    FROM price_changes pc
    JOIN order_items oi ON pc.item_id = oi.item_id
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'Delivered'
    AND o.order_datetime BETWEEN DATE_SUB(pc.last_price_update, INTERVAL 30 DAY) AND DATE_ADD(pc.last_price_update, INTERVAL 30 DAY)
    GROUP BY pc.item_id, pc.restaurant_id, pc.item_category, pc.restaurant_category, pc.price_change_percent, pc.base_price, pc.current_price
)
SELECT 
    item_category,
    restaurant_category,
    COUNT(*) as items_analyzed,
    ROUND(AVG(price_change_percent), 2) as avg_price_change,
    ROUND(AVG((orders_after - orders_before) / NULLIF(orders_before, 0) * 100), 2) as demand_change_percent,
    ROUND(AVG(((orders_after - orders_before) / NULLIF(orders_before, 0)) / NULLIF(price_change_percent / 100, 0)), 3) as price_elasticity
FROM demand_analysis
WHERE orders_before > 0 AND orders_after > 0
GROUP BY item_category, restaurant_category
ORDER BY price_elasticity;
