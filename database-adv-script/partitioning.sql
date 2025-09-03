-- Table Partitioning Implementation for Performance Optimization
-- Objective: Implement partitioning on Booking table based on start_date column

-- =====================================================
-- BACKUP EXISTING BOOKING TABLE
-- =====================================================

-- Create backup of original Booking table
CREATE TABLE Booking_backup AS SELECT * FROM Booking;

-- Verify backup
SELECT COUNT(*) as backup_count FROM Booking_backup;

-- =====================================================
-- CREATE PARTITIONED BOOKING TABLE
-- =====================================================

-- Drop existing Booking table (after backup)
DROP TABLE Booking;

-- Create new partitioned Booking table
CREATE TABLE Booking (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (booking_id, start_date),
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
)
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p_2020 VALUES LESS THAN (2021),
    PARTITION p_2021 VALUES LESS THAN (2022),
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_2024 VALUES LESS THAN (2025),
    PARTITION p_2025 VALUES LESS THAN (2026),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Alternative: Monthly partitioning for more granular control
-- DROP TABLE Booking;
-- CREATE TABLE Booking (
--     booking_id UUID NOT NULL,
--     property_id UUID NOT NULL,
--     user_id UUID NOT NULL,
--     start_date DATE NOT NULL,
--     end_date DATE NOT NULL,
--     total_price DECIMAL NOT NULL,
--     status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
--     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
--     PRIMARY KEY (booking_id, start_date),
--     FOREIGN KEY (property_id) REFERENCES Property(property_id),
--     FOREIGN KEY (user_id) REFERENCES User(user_id)
-- )
-- PARTITION BY RANGE (TO_DAYS(start_date)) (
--     PARTITION p_202301 VALUES LESS THAN (TO_DAYS('2023-02-01')),
--     PARTITION p_202302 VALUES LESS THAN (TO_DAYS('2023-03-01')),
--     PARTITION p_202303 VALUES LESS THAN (TO_DAYS('2023-04-01')),
--     PARTITION p_202304 VALUES LESS THAN (TO_DAYS('2023-05-01')),
--     PARTITION p_202305 VALUES LESS THAN (TO_DAYS('2023-06-01')),
--     PARTITION p_202306 VALUES LESS THAN (TO_DAYS('2023-07-01')),
--     PARTITION p_202307 VALUES LESS THAN (TO_DAYS('2023-08-01')),
--     PARTITION p_202308 VALUES LESS THAN (TO_DAYS('2023-09-01')),
--     PARTITION p_202309 VALUES LESS THAN (TO_DAYS('2023-10-01')),
--     PARTITION p_202310 VALUES LESS THAN (TO_DAYS('2023-11-01')),
--     PARTITION p_202311 VALUES LESS THAN (TO_DAYS('2023-12-01')),
--     PARTITION p_202312 VALUES LESS THAN (TO_DAYS('2024-01-01')),
--     PARTITION p_202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
--     PARTITION p_202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
--     PARTITION p_202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
--     PARTITION p_202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
--     PARTITION p_202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
--     PARTITION p_202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
--     PARTITION p_202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
--     PARTITION p_202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
--     PARTITION p_202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
--     PARTITION p_202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
--     PARTITION p_202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
--     PARTITION p_202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
--     PARTITION p_future VALUES LESS THAN MAXVALUE
-- );

-- =====================================================
-- RESTORE DATA TO PARTITIONED TABLE
-- =====================================================

-- Insert data from backup to partitioned table
INSERT INTO Booking 
SELECT booking_id, property_id, user_id, start_date, end_date, 
       total_price, status, created_at
FROM Booking_backup;

-- Verify data restoration
SELECT COUNT(*) as restored_count FROM Booking;

-- =====================================================
-- CREATE INDEXES ON PARTITIONED TABLE
-- =====================================================

-- Indexes for optimal performance on partitioned table
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_status_start_date ON Booking(status, start_date);

-- =====================================================
-- PARTITION MANAGEMENT PROCEDURES
-- =====================================================

-- Procedure to add new yearly partitions
DELIMITER //
CREATE PROCEDURE AddYearlyPartition(IN year_val INT)
BEGIN
    SET @sql = CONCAT('ALTER TABLE Booking ADD PARTITION (PARTITION p_', 
                     year_val, ' VALUES LESS THAN (', (year_val + 1), '))');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Added partition for year ', year_val) AS result;
END //
DELIMITER ;

-- Procedure to drop old partitions (for data retention)
DELIMITER //
CREATE PROCEDURE DropOldPartition(IN partition_name VARCHAR(50))
BEGIN
    SET @sql = CONCAT('ALTER TABLE Booking DROP PARTITION ', partition_name);
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Dropped partition ', partition_name) AS result;
END //
DELIMITER ;

-- =====================================================
-- PERFORMANCE TEST QUERIES
-- =====================================================

-- Test Query 1: Date range query (single partition)
SELECT 
    booking_id, 
    start_date, 
    end_date, 
    total_price, 
    status
FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-03-31'
ORDER BY start_date;

-- Test Query 2: Date range query (multiple partitions)
SELECT 
    booking_id, 
    start_date, 
    end_date, 
    total_price, 
    status
FROM Booking
WHERE start_date BETWEEN '2023-06-01' AND '2024-06-30'
ORDER BY start_date;

-- Test Query 3: Specific month query (partition pruning)
SELECT 
    COUNT(*) as booking_count,
    AVG(total_price) as avg_price,
    status
FROM Booking
WHERE start_date >= '2024-07-01' 
  AND start_date < '2024-08-01'
GROUP BY status;

-- Test Query 4: Year-based aggregation
SELECT 
    YEAR(start_date) as booking_year,
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM Booking
WHERE YEAR(start_date) = 2024
GROUP BY YEAR(start_date);

-- Test Query 5: Cross-partition query
SELECT 
    YEAR(start_date) as year,
    MONTH(start_date) as month,
    COUNT(*) as bookings,
    SUM(total_price) as revenue
FROM Booking
WHERE start_date >= '2023-01-01' 
  AND start_date <= '2024-12-31'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY year, month;

-- =====================================================
-- EXPLAIN QUERIES FOR PERFORMANCE ANALYSIS
-- =====================================================

-- Analyze partition pruning for single partition query
EXPLAIN PARTITIONS
SELECT booking_id, start_date, total_price
FROM Booking
WHERE start_date BETWEEN '2024-01-01' AND '2024-03-31';

-- Analyze partition pruning for multi-partition query
EXPLAIN PARTITIONS
SELECT booking_id, start_date, total_price
FROM Booking
WHERE start_date BETWEEN '2023-06-01' AND '2024-06-30';

-- Analyze full table scan (no partition pruning)
EXPLAIN PARTITIONS
SELECT booking_id, start_date, total_price
FROM Booking
WHERE total_price > 1000;

-- Compare with non-partitioned performance using backup table
EXPLAIN 
SELECT booking_id, start_date, total_price
FROM Booking_backup
WHERE start_date BETWEEN '2024-01-01' AND '2024-03-31';

-- =====================================================
-- PARTITION INFORMATION QUERIES
-- =====================================================

-- View partition information
SELECT 
    PARTITION_NAME,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    DATA_LENGTH,
    INDEX_LENGTH
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL;

-- Check partition pruning in execution
SELECT 
    PARTITION_NAME,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH / 1024 / 1024 as DATA_SIZE_MB
FROM information_schema.PARTITIONS
WHERE TABLE_SCHEMA = DATABASE() 
  AND TABLE_NAME = 'Booking'
  AND PARTITION_NAME IS NOT NULL
ORDER BY PARTITION_NAME;

-- =====================================================
-- MAINTENANCE AND OPTIMIZATION COMMANDS
-- =====================================================

-- Analyze partitioned table for better query planning
ANALYZE TABLE Booking;

-- Optimize partitions to reclaim space
-- ALTER TABLE Booking OPTIMIZE PARTITION p_2024;

-- Rebuild partition statistics
-- ALTER TABLE Booking ANALYZE PARTITION ALL;

-- Check partition status
-- ALTER TABLE Booking CHECK PARTITION ALL;

-- =====================================================
-- PERFORMANCE BENCHMARKING QUERIES
-- =====================================================

-- Benchmark Query 1: Large date range on partitioned table
SELECT BENCHMARK(1000, (
    SELECT COUNT(*) 
    FROM Booking 
    WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
)) as partitioned_performance;

-- Benchmark Query 2: Same query on non-partitioned backup
SELECT BENCHMARK(1000, (
    SELECT COUNT(*) 
    FROM Booking_backup 
    WHERE start_date BETWEEN '2024-01-01' AND '2024-12-31'
)) as non_partitioned_performance;

-- Timing comparison for aggregation queries
SET @start_time = NOW(6);
SELECT 
    YEAR(start_date) as year,
    COUNT(*) as bookings,
    AVG(total_price) as avg_price
FROM Booking
WHERE start_date >= '2023-01-01'
GROUP BY YEAR(start_date);
SET @partitioned_time = TIMESTAMPDIFF(MICROSECOND, @start_time, NOW(6));

SET @start_time = NOW(6);
SELECT 
    YEAR(start_date) as year,
    COUNT(*) as bookings,
    AVG(total_price) as avg_price
FROM Booking_backup
WHERE start_date >= '2023-01-01'
GROUP BY YEAR(start_date);
SET @non_partitioned_time = TIMESTAMPDIFF(MICROSECOND, @start_time, NOW(6));

SELECT 
    @partitioned_time as partitioned_microseconds,
    @non_partitioned_time as non_partitioned_microseconds,
    ROUND((@non_partitioned_time - @partitioned_time) / @non_partitioned_time * 100, 2) as improvement_percentage;