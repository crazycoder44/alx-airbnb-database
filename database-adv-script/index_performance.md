# Database Index Performance Analysis

## Objective

Identify and create indexes to improve query performance by analyzing high-usage columns in the User, Booking, and Property tables.

## High-Usage Column Analysis

### User Table High-Usage Columns

**Frequently Used in WHERE/JOIN Clauses:**
- `user_id` (Primary Key) - Already indexed automatically
- `email` - Used for login authentication and user lookups
- `role` - Used for filtering users by type (guest, host, admin)
- `created_at` - Used for date range queries and user registration analysis

**Usage Patterns:**
- Login queries: `WHERE email = ?`
- Role-based filtering: `WHERE role = ?`
- User registration analysis: `WHERE created_at BETWEEN ? AND ?`
- Join operations: `JOIN User ON booking.user_id = user.user_id`

### Booking Table High-Usage Columns

**Frequently Used in WHERE/JOIN/ORDER BY Clauses:**
- `booking_id` (Primary Key) - Already indexed automatically
- `property_id` - Used in JOINs with Property table
- `user_id` - Used in JOINs with User table
- `start_date` - Used for date range searches and availability checks
- `end_date` - Used for date range searches and availability checks
- `status` - Used for filtering bookings by status
- `created_at` - Used for temporal analysis and reporting

**Usage Patterns:**
- Property booking lookups: `WHERE property_id = ?`
- User booking history: `WHERE user_id = ?`
- Date range searches: `WHERE start_date >= ? AND end_date <= ?`
- Status filtering: `WHERE status = 'confirmed'`
- Temporal analysis: `ORDER BY created_at DESC`

### Property Table High-Usage Columns

**Frequently Used in WHERE/JOIN/ORDER BY Clauses:**
- `property_id` (Primary Key) - Already indexed automatically
- `host_id` - Used in JOINs with User table for host information
- `location` - Used for location-based searches
- `pricepernight` - Used for price range filtering and sorting
- `created_at` - Used for temporal analysis

**Usage Patterns:**
- Location searches: `WHERE location LIKE '%city%'`
- Host property lookups: `WHERE host_id = ?`
- Price filtering: `WHERE pricepernight BETWEEN ? AND ?`
- Price sorting: `ORDER BY pricepernight ASC/DESC`
- New property analysis: `ORDER BY created_at DESC`

## Recommended Indexes

### SQL CREATE INDEX Commands

```sql
-- User table indexes
CREATE INDEX idx_user_email ON User(email);
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Booking table indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Property table indexes
CREATE INDEX idx_property_host_id ON Property(host_id);
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_pricepernight ON Property(pricepernight);
CREATE INDEX idx_property_created_at ON Property(created_at);

-- Composite indexes for common query patterns
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- Review table indexes (for related queries)
CREATE INDEX idx_review_property_id ON Review(property_id);
CREATE INDEX idx_review_user_id ON Review(user_id);
CREATE INDEX idx_review_rating ON Review(rating);

-- Payment table indexes (for related queries)
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);
CREATE INDEX idx_payment_method ON Payment(payment_method);
```

## Query Performance Analysis

### Test Query 1: User Login Authentication

**Query:**
```sql
SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'john.doe@example.com';
```

**Before Index (without idx_user_email):**
```sql
EXPLAIN SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'john.doe@example.com';
```

**Expected Result Before Index:**
```
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows | Extra       |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
|  1 | SIMPLE      | User  | ALL  | NULL          | NULL | NULL    | NULL | 5000 | Using where |
+----+-------------+-------+------+---------------+------+---------+------+------+-------------+
```

**After Index (with idx_user_email):**
```sql
-- Create the index first
CREATE INDEX idx_user_email ON User(email);

-- Then explain the same query
EXPLAIN SELECT user_id, first_name, last_name, role 
FROM User 
WHERE email = 'john.doe@example.com';
```

**Expected Result After Index:**
```
+----+-------------+-------+------+---------------+----------------+---------+-------+------+-------+
| id | select_type | table | type | possible_keys | key            | key_len | ref   | rows | Extra |
+----+-------------+-------+------+---------------+----------------+---------+-------+------+-------+
|  1 | SIMPLE      | User  | ref  | idx_user_email| idx_user_email | 767     | const |    1 | NULL  |
+----+-------------+-------+------+---------------+----------------+---------+-------+------+-------+
```

**Performance Improvement:**
- **Scan type**: Changed from `ALL` (full table scan) to `ref` (index lookup)
- **Rows examined**: Reduced from ~5000 to 1
- **Key used**: Now using `idx_user_email` index
- **Performance gain**: ~5000x improvement in row examination

### Test Query 2: Property Booking Count

**Query:**
```sql
SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC;
```

**Before Indexes:**
```sql
EXPLAIN SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC;
```

**Expected Result Before Indexes:**
```
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------------------------------------+
| id | select_type | table | type | possible_keys | key  | key_len | ref  | rows  | Extra                                        |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------------------------------------+
|  1 | SIMPLE      | p     | ALL  | PRIMARY       | NULL | NULL    | NULL |  1000 | Using temporary; Using filesort             |
|  1 | SIMPLE      | b     | ALL  | NULL          | NULL | NULL    | NULL | 15000 | Using where; Using join buffer (hash join)  |
+----+-------------+-------+------+---------------+------+---------+------+-------+----------------------------------------------+
```

**After Indexes:**
```sql
-- Create the necessary indexes
CREATE INDEX idx_booking_property_id ON Booking(property_id);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_property_status ON Booking(property_id, status);

-- Then explain the same query
EXPLAIN SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM Property p
LEFT JOIN Booking b ON p.property_id = b.property_id
WHERE b.status = 'confirmed'
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC;
```

**Expected Result After Indexes:**
```
+----+-------------+-------+------+---------------------------+---------------------------+---------+--------------------+------+----------------------------------------------+
| id | select_type | table | type | possible_keys             | key                       | key_len | ref                | rows | Extra                                        |
+----+-------------+-------+------+---------------------------+---------------------------+---------+--------------------+------+----------------------------------------------+
|  1 | SIMPLE      | p     | ALL  | PRIMARY                   | PRIMARY                   | NULL    | NULL               | 1000 | Using temporary; Using filesort             |
|  1 | SIMPLE      | b     | ref  | idx_booking_property_status| idx_booking_property_status| 153    | p.property_id,const|   15 | NULL                                        |
+----+-------------+-------+------+---------------------------+---------------------------+---------+--------------------+------+----------------------------------------------+
```

**Performance Improvement:**
- **Join efficiency**: Changed from hash join to index-based ref lookup
- **Rows examined per property**: Reduced from 15000 to ~15 average
- **Index usage**: Now using composite index `idx_booking_property_status`
- **Overall improvement**: Significant reduction in I/O operations

### Test Query 3: Date Range Booking Search

**Query:**
```sql
SELECT b.booking_id, b.start_date, b.end_date, u.first_name, u.last_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
WHERE b.start_date >= '2024-01-01' 
  AND b.end_date <= '2024-12-31'
  AND b.status = 'confirmed'
ORDER BY b.start_date;
```

**Before Indexes:**
```sql
EXPLAIN SELECT b.booking_id, b.start_date, b.end_date, u.first_name, u.last_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
WHERE b.start_date >= '2024-01-01' 
  AND b.end_date <= '2024-12-31'
  AND b.status = 'confirmed'
ORDER BY b.start_date;
```

**After Indexes:**
```sql
-- Create necessary indexes
CREATE INDEX idx_booking_date_range ON Booking(start_date, end_date);
CREATE INDEX idx_booking_user_id ON Booking(user_id);
CREATE INDEX idx_booking_status ON Booking(status);

-- Explain the query
EXPLAIN SELECT b.booking_id, b.start_date, b.end_date, u.first_name, u.last_name
FROM Booking b
JOIN User u ON b.user_id = u.user_id
WHERE b.start_date >= '2024-01-01' 
  AND b.end_date <= '2024-12-31'
  AND b.status = 'confirmed'
ORDER BY b.start_date;
```

## Performance Monitoring Commands

### Using EXPLAIN
```sql
-- Basic query analysis
EXPLAIN SELECT * FROM User WHERE email = 'user@example.com';

-- Detailed analysis with cost information
EXPLAIN FORMAT=JSON SELECT * FROM User WHERE email = 'user@example.com';
```

### Using ANALYZE (MySQL 8.0+)
```sql
-- Get actual execution statistics
EXPLAIN ANALYZE SELECT 
    u.first_name, u.last_name, COUNT(b.booking_id) as booking_count
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name
ORDER BY booking_count DESC;
```

### Performance Metrics to Monitor

1. **Execution Time**: Time taken to execute the query
2. **Rows Examined**: Number of rows scanned vs rows returned
3. **Index Usage**: Which indexes are being used
4. **Join Algorithm**: Type of join algorithm used (nested loop, hash, sort-merge)
5. **Temporary Tables**: Whether temporary tables are created
6. **Filesort Operations**: Whether sorting requires disk I/O

## Index Maintenance Considerations

### Index Storage Impact
- Each index requires additional storage space
- Estimated storage overhead: 10-15% of table size per index
- Monitor disk usage after index creation

### Write Performance Impact
- Indexes slow down INSERT/UPDATE/DELETE operations
- Each write operation must update relevant indexes
- Balance between read performance improvement and write performance cost

### Index Monitoring Queries

```sql
-- Check index usage statistics (MySQL)
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'airbnb_db'
ORDER BY TABLE_NAME, INDEX_NAME;

-- Check index size
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    ROUND(STAT_VALUE * @@innodb_page_size / 1024 / 1024, 2) AS 'Index Size (MB)'
FROM mysql.innodb_index_stats
WHERE DATABASE_NAME = 'airbnb_db'
  AND STAT_NAME = 'size'
ORDER BY STAT_VALUE DESC;
```

## Recommendations

### Primary Recommendations
1. **Implement all single-column indexes** on high-usage columns
2. **Create composite indexes** for common query patterns
3. **Monitor query performance** regularly using EXPLAIN/ANALYZE
4. **Review and optimize** slow queries identified through monitoring

### Advanced Optimizations
1. **Partial indexes** for frequently filtered data
2. **Covering indexes** to avoid table lookups
3. **Index reorganization** for maintaining performance over time
4. **Query optimization** in conjunction with indexing strategy

### Monitoring Schedule
1. **Weekly**: Review slow query logs
2. **Monthly**: Analyze index usage statistics
3. **Quarterly**: Full performance review and optimization

## Conclusion

The implementation of these indexes should significantly improve query performance for the most common operations in the ALX Airbnb database. Key improvements include:

- **Login queries**: ~5000x improvement through email index
- **Join operations**: Major reduction in examined rows through foreign key indexes
- **Date range queries**: Efficient range scans through composite date indexes
- **Filtering operations**: Fast lookups through status and role indexes

Regular monitoring and maintenance of these indexes will ensure sustained performance improvements while balancing storage and write operation costs.