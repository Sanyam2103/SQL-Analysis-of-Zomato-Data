-- =============================================
-- 1. Database Schema Creation (schema_creation.sql)
-- =============================================
CREATE DATABASE IF NOT EXISTS zomato_analytics;
USE zomato_analytics;

DROP TABLE IF EXISTS pricing_multipliers;
DROP TABLE IF EXISTS elasticity_coefficients;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS menu_items;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS restaurants;

CREATE TABLE restaurants (
    restaurant_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(255) NOT NULL,
    locality VARCHAR(100) NOT NULL,
    cuisine_type VARCHAR(100),
    restaurant_category ENUM('Budget', 'Mid-Range', 'Premium', 'Fine Dining') NOT NULL,
    average_rating DECIMAL(3,2),
    total_reviews INT DEFAULT 0,
    opening_hours VARCHAR(50),
    delivery_available BOOLEAN DEFAULT TRUE,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    established_date DATE,
    seating_capacity INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(255),
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(15),
    address TEXT,
    registration_date DATE,
    customer_segment ENUM('Premium', 'High Value', 'Frequent', 'Price Sensitive', 'Occasional'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    item_name VARCHAR(255) NOT NULL,
    item_category VARCHAR(100),
    base_price DECIMAL(8,2) NOT NULL,
    current_price DECIMAL(8,2) NOT NULL,
    preparation_time_minutes INT,
    availability_status BOOLEAN DEFAULT TRUE,
    popularity_score DECIMAL(3,2),
    cost_of_goods_sold DECIMAL(8,2),
    last_price_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id) ON DELETE CASCADE
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT,
    customer_id INT,
    order_datetime TIMESTAMP NOT NULL,
    order_value DECIMAL(10,2) NOT NULL,
    discount_applied DECIMAL(5,2) DEFAULT 0,
    delivery_fee DECIMAL(5,2) DEFAULT 0,
    payment_method ENUM('Credit Card', 'Debit Card', 'Digital Wallet', 'Cash') NOT NULL,
    order_status ENUM('Placed', 'Confirmed', 'Preparing', 'Out for Delivery', 'Delivered') NOT NULL,
    delivery_time_minutes INT,
    weather_condition VARCHAR(50),
    special_event_flag BOOLEAN DEFAULT FALSE,
    peak_hour_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    item_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(8,2) NOT NULL,
    total_price DECIMAL(8,2) NOT NULL,
    special_instructions TEXT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE elasticity_coefficients (
    elasticity_id INT PRIMARY KEY AUTO_INCREMENT,
    item_category VARCHAR(100),
    restaurant_category VARCHAR(50),
    price_elasticity DECIMAL(6,3),
    confidence_level DECIMAL(3,2),
    sample_size INT,
    calculation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_category (item_category, restaurant_category)
);

CREATE TABLE pricing_multipliers (
    multiplier_id INT PRIMARY KEY AUTO_INCREMENT,
    condition_type ENUM('Weather', 'Event', 'Season', 'Inventory', 'Time') NOT NULL,
    condition_value VARCHAR(100) NOT NULL,
    restaurant_category VARCHAR(50),
    item_category VARCHAR(100),
    multiplier_factor DECIMAL(4,3) NOT NULL,
    effective_start_time TIME,
    effective_end_time TIME,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_datetime ON orders(order_datetime);
CREATE INDEX idx_orders_restaurant ON orders(restaurant_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_menu_restaurant ON menu_items(restaurant_id);
CREATE INDEX idx_restaurants_locality ON restaurants(locality);
CREATE INDEX idx_restaurants_category ON restaurants(restaurant_category);

DELIMITER //
CREATE TRIGGER update_menu_price_timestamp 
BEFORE UPDATE ON menu_items
FOR EACH ROW
BEGIN
    IF NEW.current_price != OLD.current_price THEN
        SET NEW.last_price_update = CURRENT_TIMESTAMP;
    END IF;
END //

CREATE TRIGGER update_peak_hour_flag
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    DECLARE hour_of_day INT;
    SET hour_of_day = HOUR(NEW.order_datetime);
    IF (hour_of_day BETWEEN 12 AND 14) OR (hour_of_day BETWEEN 19 AND 22) THEN
        SET NEW.peak_hour_flag = TRUE;
    END IF;
END //
DELIMITER ;

SELECT 'Database schema created successfully!' as Status;
