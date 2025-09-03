-- Database Index Creation Script
-- Objective: Create indexes to improve query performance on high-usage columns

-- =====================================================
-- USER TABLE INDEXES
-- =====================================================

-- Index for email column (used in login authentication)
CREATE INDEX idx_user_email ON User(email);

-- Index for role column (used for filtering users by type)
CREATE INDEX idx_user_role ON User(role);

-- Index for created_at column (used for temporal analysis)
CREATE INDEX idx_user_created_at ON User(created_at);

-- =====================================================
-- BOOKING TABLE INDEXES
-- =====================================================

-- Index for property_id column (used in JOINs with Property table)
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- Index for user_id column (used in JOINs with User table)
CREATE INDEX idx_booking_user_id ON Booking(user_id);

-- Index for start_date column (used for date range searches)
CREATE INDEX idx_booking_start_date ON Booking(start_date);

-- Index for end_date column (used for date range searches)
CREATE INDEX idx_booking_end_date ON Booking(end_date);

-- Index for status column (used for filtering bookings by status)
CREATE INDEX idx_booking_status ON Booking(status);

-- Index for created_at column (used for temporal analysis)
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- =====================================================
-- PROPERTY TABLE INDEXES
-- =====================================================

-- Index for host_id column (used in JOINs with User table)
CREATE INDEX idx_property_host_id ON Property(host_id);

-- Index for location column (used for location-based searches)
CREATE INDEX idx_property_location ON Property(location);

-- Index for pricepernight column (used for price filtering and sorting)
CREATE INDEX idx_property_pricepernight ON Property(pricepernight);

-- Index for created_at column (used for temporal analysis)
CREATE INDEX idx_property_created_at ON Property(created_at);

-- =====================================================
-- COMPOSITE INDEXES FOR COMMON QUERY PATTERNS
-- =====================================================

-- Composite index for date range queries on bookings
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);

-- Composite index for property and status filtering
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);

-- Composite index for user and status filtering
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);

-- Composite index for location and price filtering
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- =====================================================
-- ADDITIONAL INDEXES FOR RELATED TABLES
-- =====================================================

-- Review table indexes
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);

-- Payment table indexes  
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_method ON Payment(payment_method);

-- =====================================================
-- PERFORMANCE MEASUREMENT QUERIES
-- =====================================================

-- Query 1: User login authentication (Before and After Index Analysis)
-- Before creating idx_user_email
-- EXPLAIN SELECT user_id, first_name, last_name, role FROM User WHERE email = 'john.doe@example.com';

-- After creating idx_user_email  
-- EXPLAIN SELECT user_id, first_name, last_name, role FROM User WHERE email = 'john.doe@example.com';

-- Query 2: Property booking count with status filtering
-- EXPLAIN ANALYZE SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
-- FROM Property p
-- LEFT JOIN Booking b ON p.property_id = b.property_id
-- WHERE b.status = 'confirmed'
-- GROUP BY p.property_id, p.name
-- ORDER BY booking_count DESC;

-- Query 3: Date range booking search with joins
-- EXPLAIN ANALYZE SELECT b.booking_id, b.start_date, b.end_date, u.first_name, u.last_name
-- FROM Booking b
-- JOIN User u ON b.user_id = u.user_id
-- WHERE b.start_date >= '2024-01-01' 
--   AND b.end_date <= '2024-12-31'
--   AND b.status = 'confirmed'
-- ORDER BY b.start_date;

-- Query 4: Property search by location and price range
-- EXPLAIN ANALYZE SELECT property_id, name, location, pricepernight
-- FROM Property
-- WHERE location LIKE '%New York%'
--   AND pricepernight BETWEEN 100 AND 300
-- ORDER BY pricepernight ASC;

-- Query 5: User booking history with status
-- EXPLAIN ANALYZE SELECT u.first_name, u.last_name, b.start_date, b.end_date, b.status
-- FROM User u
-- JOIN Booking b ON u.user_id = b.user_id
-- WHERE u.email = 'user@example.com'
--   AND b.status IN ('confirmed', 'pending')
-- ORDER BY b.start_date DESC;

-- =====================================================
-- INDEX MONITORING QUERIES
-- =====================================================

-- Check index usage statistics
-- SELECT TABLE_SCHEMA, TABLE_NAME, INDEX_NAME, CARDINALITY
-- FROM information_schema.STATISTICS
-- WHERE TABLE_SCHEMA = 'airbnb_db'
-- ORDER BY TABLE_NAME, INDEX_NAME;

-- Check index size
-- SELECT TABLE_NAME, INDEX_NAME, 
--        ROUND(STAT_VALUE * @@innodb_page_size / 1024 / 1024, 2) AS 'Index Size (MB)'
-- FROM mysql.innodb_index_stats
-- WHERE DATABASE_NAME = 'airbnb_db' AND STAT_NAME = 'size'
-- ORDER BY STAT_VALUE DESC;