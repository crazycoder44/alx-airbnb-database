# SQL Advanced Queries

This directory contains SQL queries demonstrating advanced database operations including different types of joins, subqueries, aggregations, and window functions for the ALX Airbnb Database project.

## Objectives

1. **Master SQL joins** by writing complex queries using different types of joins to retrieve data from multiple related tables
2. **Write both correlated and non-correlated subqueries** to perform complex data retrieval operations using nested SELECT statements
3. **Use SQL aggregation and window functions** to analyze data with advanced analytical capabilities

## Files

- `joins_queries.sql` - Contains all SQL join queries
- `subqueries.sql` - Contains all subquery examples
- `aggregations_and_window_functions.sql` - Contains aggregation and window function queries
- `README.md` - This documentation file

## Database Schema

The queries work with the following main tables:
- **User**: User information (user_id, first_name, last_name, email, role)
- **Property**: Property details (property_id, name, description, location, pricepernight)
- **Booking**: Booking records (booking_id, property_id, user_id, start_date, end_date, total_price, status)
- **Review**: Property reviews (review_id, property_id, user_id, rating, comment, created_at)
- **Payment**: Payment information (payment_id, booking_id, amount, payment_method)
- **Message**: User messages (message_id, sender_id, recipient_id, message_body)

## Part 1: SQL Joins

### Query Types Implemented

#### 1. INNER JOIN Query

**Purpose**: Retrieve all bookings and the respective users who made those bookings.

**Query**: Joins the `Booking` and `User` tables to show only bookings that have matching users.

**Returns**: 
- Booking details (booking_id, start_date, end_date, total_price, status)
- User details (user_id, first_name, last_name, email)

**Use Case**: When you need to see booking information along with complete user details, excluding any orphaned bookings.

#### 2. LEFT JOIN Query

**Purpose**: Retrieve all properties and their reviews, including properties that have no reviews.

**Query**: Joins the `Property` and `Review` tables, keeping all properties even if they don't have reviews, ordered by property name.

**Returns**:
- Property details (property_id, name, location)
- Review details (review_id, rating, comment, created_at) where available
- NULL values for review fields when no reviews exist

**Use Case**: When you need a complete list of all properties, regardless of whether they have been reviewed or not.

#### 3. FULL OUTER JOIN Query

**Purpose**: Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

**Query**: Joins the `User` and `Booking` tables, showing all records from both tables regardless of matching criteria.

**Returns**:
- User details (user_id, first_name, last_name) where available
- Booking details (booking_id, start_date, end_date, status) where available
- NULL values where no match exists in either direction

**Use Case**: When you need to see all users (including those who haven't made bookings) and all bookings (including any orphaned bookings).

### Key Concepts - Joins

#### INNER JOIN
- Only returns rows where there's a match in both tables
- Most restrictive join type
- Useful for finding relationships that definitely exist

#### LEFT JOIN (LEFT OUTER JOIN)
- Returns all rows from the left table
- Includes matching rows from the right table where available
- NULL values for right table columns when no match exists
- Useful for "show me everything from table A, plus related data from table B if it exists"

#### FULL OUTER JOIN
- Returns all rows from both tables
- Shows matches where they exist
- Shows non-matching rows from both sides with NULL values
- Most comprehensive join type
- Useful for complete data analysis including orphaned records

## Part 2: SQL Subqueries

### Query Types Implemented

#### 1. Non-Correlated Subquery

**Purpose**: Find all properties where the average rating is greater than 4.0.

**Query Type**: Non-correlated subquery using IN clause with GROUP BY and HAVING

**How it works**:
1. The inner subquery executes independently of the outer query
2. Groups reviews by property_id and calculates average ratings
3. Returns property_ids where average rating > 4.0
4. The outer query retrieves property details for matching property_ids

**Returns**:
- Property details (property_id, name, description, location, pricepernight)
- Only properties with average ratings above 4.0
- Results ordered alphabetically by property name

**Key Features**:
- **Independent execution**: Subquery runs once and returns a set of values
- **GROUP BY**: Groups reviews by property to calculate averages
- **HAVING clause**: Filters groups based on aggregate conditions
- **IN operator**: Matches outer query results with subquery results

#### 2. Correlated Subquery

**Purpose**: Find users who have made more than 3 bookings.

**Query Type**: Correlated subquery using COUNT() function

**How it works**:
1. For each user in the outer query, the inner subquery executes
2. The inner subquery counts bookings for the current user (correlation)
3. Only users with more than 3 bookings are returned
4. Results are ordered by user's last name and first name

**Returns**:
- User details (user_id, first_name, last_name, email, role)
- Only users who have made more than 3 bookings
- Results ordered by last name, then first name

**Key Features**:
- **Correlated execution**: Subquery executes once for each row in outer query
- **WHERE correlation**: Inner query references outer query's user_id
- **COUNT function**: Aggregates booking count per user
- **Performance consideration**: May be slower than JOIN equivalent for large datasets

### Key Concepts - Subqueries

#### Non-Correlated Subqueries
- Execute independently of the outer query
- Run once and return a set of values
- Often more efficient than correlated subqueries
- Can be replaced with JOINs in many cases
- Useful with IN, EXISTS, ANY, ALL operators

#### Correlated Subqueries
- Reference columns from the outer query
- Execute once for each row in the outer query
- Create a dependency between inner and outer queries
- Cannot run independently
- Useful for row-by-row comparisons and calculations

#### Aggregate Functions in Subqueries
- **AVG()**: Calculate average ratings
- **COUNT()**: Count related records
- **HAVING**: Filter groups based on aggregate conditions
- **GROUP BY**: Group data for aggregate calculations

## Part 3: SQL Aggregations and Window Functions

### Query Types Implemented

#### 1. Aggregation Query

**Purpose**: Find the total number of bookings made by each user using COUNT function and GROUP BY clause.

**Query Type**: Aggregation query with LEFT JOIN and GROUP BY

**How it works**:
1. LEFT JOIN User and Booking tables to include all users
2. GROUP BY user attributes to aggregate data per user
3. COUNT booking_id to get total bookings per user
4. ORDER BY total bookings (descending) and user name

**Returns**:
- User details (user_id, first_name, last_name, email)
- Total booking count per user (including 0 for users with no bookings)
- Results ordered by booking count (highest first), then by name

**Key Features**:
- **LEFT JOIN**: Includes users with zero bookings
- **COUNT function**: Counts non-NULL booking_id values
- **GROUP BY**: Aggregates data by user
- **Multiple ORDER BY**: Sorts by booking count, then by name

#### 2. Window Function Query with ROW_NUMBER

**Purpose**: Rank properties based on total number of bookings using ROW_NUMBER window function.

**Query Type**: Window function with aggregation

**How it works**:
1. GROUP BY property attributes and count bookings
2. ROW_NUMBER() assigns unique sequential ranks
3. ORDER BY booking count (descending) within the window function
4. Results ordered by the calculated rank

**Returns**:
- Property details (property_id, name, location, pricepernight)
- Total bookings per property
- Unique sequential ranking (1, 2, 3, 4...)

**Key Features**:
- **ROW_NUMBER()**: Assigns unique sequential numbers
- **OVER clause**: Defines the window for ranking
- **No ties**: Each property gets a unique rank even with equal booking counts

#### 3. Window Function Query with RANK

**Purpose**: Rank properties using RANK and DENSE_RANK functions to handle ties appropriately.

**Query Type**: Window function demonstrating different ranking methods

**How it works**:
1. Same grouping and counting as ROW_NUMBER query
2. RANK() handles ties by giving same rank, then skipping numbers
3. DENSE_RANK() handles ties without skipping subsequent numbers
4. Demonstrates different approaches to handling equal values

**Returns**:
- Property details and booking counts
- Three different ranking columns showing different tie-handling methods
- Comparison of ROW_NUMBER, RANK, and DENSE_RANK behaviors

**Key Features**:
- **RANK()**: Handles ties, skips subsequent ranks (1, 2, 2, 4...)
- **DENSE_RANK()**: Handles ties, no gaps in ranking (1, 2, 2, 3...)
- **Multiple window functions**: Shows different ranking strategies

### Key Concepts - Aggregations and Window Functions

#### Aggregation Functions
- **COUNT()**: Count non-NULL values
- **GROUP BY**: Group rows for aggregate calculations
- **LEFT JOIN with aggregation**: Include all records from left table
- **ORDER BY with aggregates**: Sort by calculated values

#### Window Functions
- **ROW_NUMBER()**: Assigns unique sequential numbers
- **RANK()**: Assigns ranks with gaps for ties
- **DENSE_RANK()**: Assigns ranks without gaps for ties
- **OVER clause**: Defines the window specification
- **Partitioning and ordering**: Control how window functions operate

#### Window Functions vs Aggregations
- **Aggregations**: Reduce rows (GROUP BY collapses rows)
- **Window functions**: Keep all rows while adding analytical data
- **OVER clause**: Defines calculation window without collapsing rows
- **Performance**: Window functions can be more efficient than subqueries

## Performance Considerations

### Joins Performance
- **INNER JOIN**: Generally fastest, especially with proper indexes
- **LEFT JOIN**: Moderate performance, depends on data distribution
- **FULL OUTER JOIN**: Can be slower, especially on large datasets

### Subqueries Performance

#### Non-Correlated Subquery
- Executes once regardless of outer query size
- Generally more efficient
- Can benefit from indexes on Review(property_id) and Review(rating)

#### Correlated Subquery
- Executes N times where N = number of users
- May be less efficient for large datasets
- Benefits from index on Booking(user_id)
- Consider JOIN alternative for better performance

### Aggregations and Window Functions Performance

#### Aggregation Functions
- **GROUP BY**: Performance depends on indexes and data distribution
- **COUNT()**: Generally fast, especially with indexes
- **ORDER BY**: Benefits from indexes on sorted columns

#### Window Functions
- **ROW_NUMBER()**: Generally efficient for sequential ranking
- **RANK/DENSE_RANK**: Slightly more overhead than ROW_NUMBER()
- **OVER clause**: Performance depends on partition and order specifications
- **Memory usage**: Window functions may require more memory for large result sets

## Alternative Approaches

### Subquery Alternatives Using JOINs

#### Query 1 Alternative:
```sql
SELECT DISTINCT p.property_id, p.name, p.description, p.location, p.pricepernight
FROM Property p
INNER JOIN (
    SELECT property_id
    FROM Review
    GROUP BY property_id
    HAVING AVG(rating) > 4.0
) r ON p.property_id = r.property_id;
```

#### Query 2 Alternative:
```sql
SELECT u.user_id, u.first_name, u.last_name, u.email, u.role
FROM User u
INNER JOIN (
    SELECT user_id
    FROM Booking
    GROUP BY user_id
    HAVING COUNT(*) > 3
) b ON u.user_id = b.user_id;
```

### Window Function Alternative Using Subqueries:
```sql
SELECT p.*, booking_counts.total_bookings,
       @row_number := @row_number + 1 AS booking_rank
FROM Property p
JOIN (
    SELECT property_id, COUNT(*) as total_bookings
    FROM Booking
    GROUP BY property_id
    ORDER BY COUNT(*) DESC
) booking_counts ON p.property_id = booking_counts.property_id
CROSS JOIN (SELECT @row_number := 0) r
ORDER BY booking_counts.total_bookings DESC;
```

## Usage Instructions

1. Ensure you have access to the ALX Airbnb database
2. Run the queries in the respective SQL files in your SQL environment:
   - `joins_queries.sql` for join operations
   - `subqueries.sql` for subquery examples
   - `aggregations_and_window_functions.sql` for aggregation and window function examples
3. Each query can be executed independently
4. Review the results to understand how different techniques affect the output
5. Compare execution plans to understand performance characteristics
6. Use EXPLAIN or ANALYZE commands to study query performance

## Expected Results

### Joins Results
- **INNER JOIN**: Only bookings with valid users
- **LEFT JOIN**: All properties, with review data where it exists
- **FULL OUTER JOIN**: Complete view of users and bookings relationship

### Subqueries Results
- **Non-correlated subquery**: Properties with high ratings (>4.0 average)
- **Correlated subquery**: Active users with multiple bookings (>3 bookings)

### Aggregations and Window Functions Results
- **Aggregation query**: User booking counts (including users with 0 bookings)
- **ROW_NUMBER query**: Properties ranked by booking count with unique sequential ranks
- **RANK query**: Properties ranked with proper tie handling using different ranking methods

## Indexes for Optimization

The following indexes support these queries:
- `idx_user_email` - User login lookup
- `idx_property_host_id` - Property-host relationships
- `idx_property_id` - Property detail retrieval
- `idx_booking_property_id` - Property-booking relationships (crucial for aggregations)
- `idx_booking_user_id` - User-booking relationships (crucial for user booking counts)
- `idx_review_property_id` - Property-review relationships
- `idx_payment_booking_id` - Booking-payment relationships

## Notes

- These queries assume proper foreign key relationships between tables
- FULL OUTER JOIN syntax may vary depending on your SQL database system
- Window functions are supported in modern SQL databases (MySQL 8.0+, PostgreSQL, SQL Server, Oracle)
- Always verify your database schema matches the assumed structure before executing queries
- Consider performance implications when choosing between JOINs, subqueries, and window functions
- Use EXPLAIN or ANALYZE commands to understand query execution plans
- Window functions provide powerful analytical capabilities while maintaining row-level detail

## Repository Information

- **Repository**: alx-airbnb-database
- **Directory**: database-adv-script
- **Files**: joins_queries.sql, subqueries.sql, aggregations_and_window_functions.sql, README.md