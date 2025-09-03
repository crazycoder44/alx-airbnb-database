# Database Index Performance Analysis

## Objective

Identify and create indexes to improve query performance by analyzing high-usage columns in the User, Booking, and Property tables.

## Files

- `database_index.sql` - Contains all CREATE INDEX commands and performance measurement queries
- `index_performance.md` - This documentation file with analysis and results

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

All index creation commands are implemented in `database_index.sql`. The file includes:

### Single-Column Indexes

**User Table:**
- `idx_user_email` - For login authentication
- `idx_user_role` - For user type filtering  
- `idx_user_created_at` - For temporal analysis

**Booking Table:**
- `idx_booking_property_id` - For property-booking joins
- `idx_booking_user_id` - For user-booking joins
- `idx_booking_start_date` - For date range searches
- `idx_booking_end_date` - For date range searches
- `idx_booking_status` - For status filtering
- `idx_booking_created_at` - For temporal analysis

**Property Table:**
- `idx_property_host_id` - For host-property joins
- `idx_property_location` - For location searches
- `idx_property_pricepernight` - For price filtering/sorting
- `idx_property_created_at` - For temporal analysis

### Composite Indexes

- `idx_booking_date_range` - For efficient date range queries
- `idx_booking_property_status` - For property-specific status filtering
- `idx_booking_user_status` - For user-specific status filtering  
- `idx_property_location_price` - For location and price filtering

### Additional Related Table Indexes

- Review table indexes for property and user relationships
- Payment table indexes for booking relationships

## Query Performance Measurements

The `database_index.sql` file includes commented EXPLAIN and ANALYZE queries to measure performance before and after index creation.

### Test Scenarios Included

1. **User Login Authentication**
   - Tests email-based user lookup performance
   - Demonstrates impact of `idx_user_email`

2. **Property Booking Analysis**
   - Tests complex JOIN with GROUP BY and filtering
   - Shows composite index effectiveness

3. **Date Range Booking Searches**
   - Tests date range queries with multiple JOINs
   - Demonstrates `idx_booking_date_range` performance

4. **Location and Price Filtering**
   - Tests property search with multiple criteria
   - Shows `idx_property_location_price` composite index benefits

5. **User Booking History**
   - Tests user-specific booking retrieval
   - Demonstrates foreign key index performance

## Performance Analysis Results

### Before Index Implementation

**Typical Performance Issues:**
- Full table scans on large tables (type: ALL)
- Hash joins instead of efficient index lookups
- High row examination counts
- Using temporary tables and filesort operations
- Slow response times for common queries

### After Index Implementation

**Expected Improvements:**

#### User Login Queries
- **Scan Type**: Changed from `ALL` to `ref`
- **Rows Examined**: Reduced from ~5000 to 1
- **Performance Gain**: ~5000x improvement

#### Property-Booking JOIN Queries  
- **Join Algorithm**: Changed from hash join to index-based joins
- **Index Usage**: Utilizes `idx_booking_property_id` and composite indexes
- **Rows Examined**: Significant reduction in examined rows per operation

#### Date Range Searches
- **Range Scans**: Efficient range operations using `idx_booking_date_range`
- **Sort Operations**: Reduced filesort operations
- **Overall Performance**: Major improvement in date-based queries

#### Location-Based Searches
- **Text Searches**: Improved LIKE operations with `idx_property_location`
- **Price Filtering**: Efficient range scans with price indexes
- **Combined Filtering**: Optimized multi-criteria searches

## How to Use the Performance Measurement

### Step 1: Measure Baseline Performance
```sql
-- Run these queries BEFORE creating indexes
EXPLAIN SELECT user_id, first_name, last_name, role 
FROM User WHERE email = 'john.doe@example.com';
```

### Step 2: Create Indexes
```sql
-- Execute the database_index.sql file
SOURCE database_index.sql;
-- OR
mysql -u username -p database_name < database_index.sql
```

### Step 3: Measure Improved Performance  
```sql
-- Run the same queries AFTER creating indexes
EXPLAIN SELECT user_id, first_name, last_name, role 
FROM User WHERE email = 'john.doe@example.com';
```

### Step 4: Compare Results
- Compare execution plans
- Note changes in:
  - Query type (ALL → ref/range)
  - Rows examined
  - Key usage
  - Extra operations

## Performance Monitoring Commands

### Using EXPLAIN
```sql
-- Basic analysis
EXPLAIN SELECT * FROM User WHERE email = 'user@example.com';

-- Detailed analysis  
EXPLAIN FORMAT=JSON SELECT * FROM User WHERE email = 'user@example.com';
```

### Using ANALYZE (MySQL 8.0+)
```sql
-- Actual execution statistics
EXPLAIN ANALYZE SELECT u.first_name, u.last_name, COUNT(b.booking_id) 
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
GROUP BY u.user_id, u.first_name, u.last_name;
```

### Index Usage Monitoring

The `database_index.sql` file includes monitoring queries to:
- Check index usage statistics
- Monitor index size and storage impact
- Identify unused or underutilized indexes

## Implementation Guidelines

### Installation Steps
1. **Backup Database**: Always backup before creating indexes
2. **Execute Script**: Run `database_index.sql` during low-traffic periods  
3. **Monitor Impact**: Use EXPLAIN/ANALYZE to verify improvements
4. **Validate Performance**: Test critical application queries

### Performance Validation
- Run performance tests on representative queries
- Monitor system resources during index creation
- Verify that write operations aren't significantly impacted
- Document performance improvements for future reference

## Index Maintenance Considerations

### Storage Impact
- Each index requires additional storage space
- Monitor disk usage after implementation
- Estimated overhead: 10-15% of table size per index

### Write Performance
- Indexes slow down INSERT/UPDATE/DELETE operations  
- Balance read performance gains against write costs
- Monitor application performance holistically

### Ongoing Monitoring
- **Weekly**: Review slow query logs
- **Monthly**: Analyze index usage statistics
- **Quarterly**: Full performance review and optimization

## Conclusion

The indexes defined in `database_index.sql` target the most critical performance bottlenecks in the ALX Airbnb database. Key improvements include:

- **Dramatic reduction** in query execution time for common operations
- **Efficient JOIN operations** through foreign key indexes
- **Optimized filtering** through status and role indexes  
- **Enhanced search capabilities** through location and price indexes
- **Improved analytical queries** through composite indexes

Regular monitoring using the provided EXPLAIN/ANALYZE queries will ensure sustained performance benefits while maintaining optimal database operations.