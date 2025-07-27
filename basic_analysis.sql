-- =============================================
-- 3. Basic Analysis Queries (basic_analysis.sql)
-- =============================================
USE zomato_analytics;

-- 1. Restaurant Performance Overview
SELECT 
    r.restaurant_name,
    r.locality,
    r.restaurant_category,
    r.average_rating,
    COUNT(DISTINCT o.order_id) as total_orders,
    ROUND(AVG(o.order_value), 2) as avg_order_value,
    ROUND(SUM(o.order_value), 2) as total_revenue,
    ROUND(AVG(o.delivery_time_minutes), 1) as avg_delivery_time,
    COUNT(DISTINCT o.customer_id) as unique_customers
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id 
    AND o.order_status = 'Delivered'
    AND o.order_datetime >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
GROUP BY r.restaurant_id
ORDER BY total_revenue DESC;

-- 2. Peak Hour Analysis
WITH hourly_analysis AS (
    SELECT 
        HOUR(order_datetime) as hour_of_day,
        COUNT(*) as order_count,
        ROUND(AVG(order_value), 2) as avg_order_value,
        ROUND(SUM(order_value), 2) as total_revenue,
        ROUND(AVG(delivery_time_minutes), 1) as avg_delivery_time
    FROM orders 
    WHERE order_status = 'Delivered'
    AND order_datetime >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    GROUP BY HOUR(order_datetime)
)
SELECT 
    hour_of_day,
    order_count,
    avg_order_value,
    total_revenue,
    avg_delivery_time,
    CASE 
        WHEN order_count > (SELECT AVG(order_count) * 1.5 FROM hourly_analysis) THEN 'Peak'
        WHEN order_count > (SELECT AVG(order_count) FROM hourly_analysis) THEN 'Moderate'
        ELSE 'Low'
    END as demand_level
FROM hourly_analysis
ORDER BY hour_of_day;

-- 3. Locality Performance Analysis
SELECT 
    r.locality,
    COUNT(DISTINCT r.restaurant_id) as restaurant_count,
    ROUND(AVG(r.average_rating), 2) as avg_locality_rating,
    COUNT(o.order_id) as total_orders,
    ROUND(AVG(o.order_value), 2) as avg_order_value,
    ROUND(SUM(o.order_value), 2) as total_revenue,
    ROUND(AVG(o.delivery_time_minutes), 1) as avg_delivery_time,
    COUNT(DISTINCT o.customer_id) as unique_customers
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
    AND o.order_datetime >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
    AND o.order_status = 'Delivered'
GROUP BY r.locality
HAVING restaurant_count >= 1
ORDER BY avg_order_value DESC;

-- 4. Menu Item Performance
SELECT 
    r.restaurant_name,
    mi.item_category,
    mi.item_name,
    mi.base_price,
    mi.current_price,
    ROUND((mi.current_price - mi.base_price) / mi.base_price * 100, 2) as price_increase_percent,
    COUNT(oi.order_item_id) as times_ordered,
    ROUND(SUM(oi.total_price), 2) as total_revenue,
    ROUND(AVG(oi.unit_price), 2) as avg_selling_price,
    mi.popularity_score
FROM menu_items mi
JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
LEFT JOIN order_items oi ON mi.item_id = oi.item_id
LEFT JOIN orders o ON oi.order_id = o.order_id 
    AND o.order_status = 'Delivered'
    AND o.order_datetime >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
WHERE mi.availability_status = TRUE
GROUP BY mi.item_id
ORDER BY total_revenue DESC;
