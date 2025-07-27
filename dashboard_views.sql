-- =============================================
-- 6. Dashboard and Monitoring Views (dashboard_views.sql)
-- =============================================
USE zomato_analytics;

-- Drop views if they exist
DROP VIEW IF EXISTS pricing_performance_dashboard;
DROP VIEW IF EXISTS restaurant_performance_summary;

-- Create pricing_performance_dashboard
CREATE VIEW pricing_performance_dashboard AS
SELECT 
    r.restaurant_name,
    r.locality,
    r.restaurant_category,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(o.order_value), 2) AS avg_order_value,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(AVG(o.delivery_time_minutes), 1) AS avg_delivery_time,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    COUNT(DISTINCT mi.item_id) AS menu_items_count,
    ROUND(AVG(mi.current_price), 2) AS avg_item_price
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id AND o.order_status = 'Delivered'
LEFT JOIN menu_items mi ON r.restaurant_id = mi.restaurant_id AND mi.availability_status = TRUE
GROUP BY r.restaurant_name, r.locality, r.restaurant_category;

-- Create restaurant_performance_summary
CREATE VIEW restaurant_performance_summary AS
SELECT 
    r.restaurant_id,
    r.restaurant_name,
    COUNT(DISTINCT o.order_id) AS order_count,
    ROUND(SUM(o.order_value), 2) AS total_revenue,
    ROUND(AVG(o.delivery_time_minutes), 1) AS avg_delivery_time,
    ROUND(AVG(o.discount_applied), 2) AS avg_discount,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
WHERE o.order_status = 'Delivered'
GROUP BY r.restaurant_id, r.restaurant_name;

SELECT 'Dashboard views created successfully!' AS Status;
