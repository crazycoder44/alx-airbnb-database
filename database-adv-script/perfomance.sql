-- Performance Optimization: Complex Query Refactoring
-- Objective: Improve performance of complex queries through optimization techniques

-- =====================================================
-- INITIAL QUERY (BEFORE OPTIMIZATION)
-- =====================================================

-- Initial complex query retrieving all bookings with user, property, and payment details
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    p.updated_at AS property_updated_at,
    
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    host.email AS host_email,
    
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
    
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- Performance analysis command for initial query
-- EXPLAIN ANALYZE SELECT ... (same query as above)

-- =====================================================
-- PERFORMANCE ANALYSIS QUERIES
-- =====================================================

-- Query to analyze the initial query performance
EXPLAIN FORMAT=JSON
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.created_at AS booking_created_at,
    
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    u.created_at AS user_created_at,
    
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    p.created_at AS property_created_at,
    p.updated_at AS property_updated_at,
    
    host.user_id AS host_id,
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    host.email AS host_email,
    
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
    
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- =====================================================
-- OPTIMIZED QUERIES (AFTER REFACTORING)
-- =====================================================

-- Optimization 1: Reduced column selection for better performance
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    u.first_name,
    u.last_name,
    u.email,
    
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    
    pay.amount AS payment_amount,
    pay.payment_method
    
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- Optimization 2: Add WHERE clause for better filtering and index usage
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    u.first_name,
    u.last_name,
    u.email,
    
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    
    pay.amount AS payment_amount,
    pay.payment_method
    
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'pending')
  AND b.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY b.created_at DESC;

-- Optimization 3: Paginated query for large result sets
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    u.first_name,
    u.last_name,
    u.email,
    
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    host.first_name AS host_first_name,
    host.last_name AS host_last_name,
    
    pay.amount AS payment_amount,
    pay.payment_method
    
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'pending')
  AND b.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY b.created_at DESC
LIMIT 50 OFFSET 0;

-- Optimization 4: Query with covering index optimization
-- This query is structured to take advantage of composite indexes
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    b.user_id,
    b.property_id
FROM Booking b
WHERE b.status = 'confirmed'
  AND b.start_date >= '2024-01-01'
  AND b.end_date <= '2024-12-31'
ORDER BY b.start_date DESC;

-- Then join only necessary data in separate queries or use EXISTS for filtering
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email
FROM User u
WHERE EXISTS (
    SELECT 1 FROM Booking b 
    WHERE b.user_id = u.user_id 
      AND b.status = 'confirmed'
      AND b.start_date >= '2024-01-01'
);

-- =====================================================
-- ALTERNATIVE APPROACH: USING STORED PROCEDURE
-- =====================================================

DELIMITER //

CREATE PROCEDURE GetBookingDetailsOptimized(
    IN p_limit INT DEFAULT 50,
    IN p_offset INT DEFAULT 0,
    IN p_status VARCHAR(20) DEFAULT NULL,
    IN p_date_from DATE DEFAULT NULL
)
BEGIN
    DECLARE sql_query TEXT DEFAULT '';
    
    SET sql_query = '
    SELECT 
        b.booking_id,
        b.start_date,
        b.end_date,
        b.total_price,
        b.status,
        u.first_name,
        u.last_name,
        u.email,
        p.name AS property_name,
        p.location,
        p.pricepernight,
        host.first_name AS host_first_name,
        host.last_name AS host_last_name,
        pay.amount AS payment_amount,
        pay.payment_method
    FROM Booking b
    FORCE INDEX (idx_booking_status, idx_booking_created_at)
    JOIN User u ON b.user_id = u.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User host ON p.host_id = host.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    WHERE 1=1';
    
    IF p_status IS NOT NULL THEN
        SET sql_query = CONCAT(sql_query, ' AND b.status = ''', p_status, '''');
    END IF;
    
    IF p_date_from IS NOT NULL THEN
        SET sql_query = CONCAT(sql_query, ' AND b.created_at >= ''', p_date_from, '''');
    END IF;
    
    SET sql_query = CONCAT(sql_query, ' ORDER BY b.created_at DESC LIMIT ', p_limit, ' OFFSET ', p_offset);
    
    SET @sql = sql_query;
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END //

DELIMITER ;

-- Usage example:
-- CALL GetBookingDetailsOptimized(25, 0, 'confirmed', '2024-01-01');

-- =====================================================
-- PERFORMANCE COMPARISON QUERIES
-- =====================================================

-- Compare initial vs optimized query performance
-- Run these to measure performance differences

-- Initial query performance
EXPLAIN ANALYZE
SELECT 
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    u.first_name, u.last_name, u.email,
    p.name AS property_name, p.location, p.pricepernight,
    host.first_name AS host_first_name, host.last_name AS host_last_name,
    pay.amount AS payment_amount, pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY b.created_at DESC;

-- Optimized query performance  
EXPLAIN ANALYZE
SELECT 
    b.booking_id, b.start_date, b.end_date, b.total_price, b.status,
    u.first_name, u.last_name, u.email,
    p.name AS property_name, p.location, p.pricepernight,
    host.first_name AS host_first_name, host.last_name AS host_last_name,
    pay.amount AS payment_amount, pay.payment_method
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Property p ON b.property_id = p.property_id
JOIN User host ON p.host_id = host.user_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.status IN ('confirmed', 'pending')
  AND b.created_at >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
ORDER BY b.created_at DESC
LIMIT 50;

-- =====================================================
-- SPECIALIZED QUERIES FOR SPECIFIC USE CASES
-- =====================================================

-- Query for dashboard summary (highly optimized)
SELECT 
    COUNT(*) as total_bookings,
    COUNT(CASE WHEN b.status = 'confirmed' THEN 1 END) as confirmed_bookings,
    COUNT(CASE WHEN b.status = 'pending' THEN 1 END) as pending_bookings,
    AVG(b.total_price) as avg_booking_price,
    COUNT(DISTINCT b.user_id) as unique_users
FROM Booking b
WHERE b.created_at >= DATE_SUB(CURDATE(), INTERVAL 30 DAY);

-- Query for user booking history (user-specific optimization)
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.status,
    p.name AS property_name,
    p.location,
    pay.payment_method
FROM Booking b
JOIN Property p ON b.property_id = p.property_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE b.user_id = ? -- Parameter for specific user
ORDER BY b.start_date DESC
LIMIT 10;