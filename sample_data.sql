-- =============================================
-- 2. Sample Data Population (sample_data.sql)
-- =============================================
USE zomato_analytics;

-- Insert sample restaurants
INSERT INTO restaurants (restaurant_name, locality, cuisine_type, restaurant_category, average_rating, total_reviews, opening_hours, seating_capacity, established_date)
VALUES
('Spice Garden', 'Koramangala', 'Indian', 'Mid-Range', 4.2, 1250, '11:00-23:00', 80, '2015-06-12'),
('Pizza Paradise', 'Indiranagar', 'Italian', 'Budget', 4.0, 890, '12:00-24:00', 60, '2019-03-08'),
('The Royal Feast', 'UB City Mall', 'Multi-Cuisine', 'Premium', 4.5, 2100, '12:00-23:30', 100, '2016-10-01');

-- Insert sample customers
INSERT INTO customers (customer_name, email, phone, address, registration_date, customer_segment)
VALUES
('Rajesh Kumar', 'rajesh.kumar@email.com', '9876543210', 'HSR Layout, Bangalore', '2021-01-05', 'Frequent'),
('Priya Sharma', 'priya.sharma@email.com', '9876543211', 'Koramangala, Bangalore', '2021-01-15', 'Premium');

-- Insert sample menu items
INSERT INTO menu_items (restaurant_id, item_name, item_category, base_price, current_price, preparation_time_minutes, popularity_score, cost_of_goods_sold)
VALUES
(1, 'Butter Chicken', 'Main Course', 320.00, 350.00, 25, 4.5, 180.00),
(1, 'Paneer Tikka', 'Appetizer', 280.00, 280.00, 20, 4.2, 150.00),
(2, 'Margherita Pizza', 'Main Course', 250.00, 280.00, 20, 4.3, 120.00);

-- Insert sample orders
INSERT INTO orders (restaurant_id, customer_id, order_datetime, order_value, discount_applied, delivery_fee, payment_method, order_status, delivery_time_minutes, weather_condition)
VALUES
(1, 1, '2024-01-15 13:30:00', 720.00, 50.00, 30.00, 'Digital Wallet', 'Delivered', 35, 'Cloudy'),
(2, 2, '2024-01-15 19:45:00', 650.00, 0.00, 25.00, 'Credit Card', 'Delivered', 28, 'Clear');

-- Insert corresponding order items
INSERT INTO order_items (order_id, item_id, quantity, unit_price, total_price)
VALUES
(1, 1, 1, 350.00, 350.00),
(1, 2, 1, 280.00, 280.00),
(2, 3, 1, 280.00, 280.00);

-- Insert pricing multipliers
INSERT INTO pricing_multipliers (condition_type, condition_value, restaurant_category, item_category, multiplier_factor, effective_start_time, effective_end_time)
VALUES
('Weather', 'Heavy Rain', 'All', 'All', 1.150, '00:00:00', '23:59:59'),
('Time', 'Peak Hours', 'All', 'All', 1.080, '19:00:00', '22:00:00');

-- Insert elasticity coefficients
INSERT INTO elasticity_coefficients (item_category, restaurant_category, price_elasticity, confidence_level, sample_size)
VALUES
('Main Course', 'Budget', -1.8, 0.85, 150),
('Appetizer', 'Mid-Range', -1.5, 0.80, 130);

SELECT 'Sample data inserted successfully!' AS Status;
