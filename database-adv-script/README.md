# SQL Advanced Queries

This directory contains SQL queries demonstrating advanced database operations including different types of joins and subqueries for the ALX Airbnb Database project.

## Objectives

1. **Master SQL joins** by writing complex queries using different types of joins to retrieve data from multiple related tables
2. **Write both correlated and non-correlated subqueries** to perform complex data retrieval operations using nested SELECT statements

## Files

- `joins_queries.sql` - Contains all SQL join queries
- `subqueries.sql` - Contains all subquery examples
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

## Usage Instructions

1. Ensure you have access to the ALX Airbnb database
2. Run the queries in `joins_queries.sql` and `subqueries.sql` in your SQL environment
3. Each query can be executed independently
4. Review the results to understand how different join types and subquery approaches affect the output
5. Compare execution plans to understand performance characteristics

## Expected Results

### Joins Results
- **INNER JOIN**: Only bookings with valid users
- **LEFT JOIN**: All properties, with review data where it exists
- **FULL OUTER JOIN**: Complete view of users and bookings relationship

### Subqueries Results
- **Non-correlated subquery**: Properties with high ratings (>4.0 average)
- **Correlated subquery**: Active users with multiple bookings (>3 bookings)

## Indexes for Optimization

The following indexes support these queries:
- `idx_user_email` - User login lookup
- `idx_property_host_id` - Property-host relationships
- `idx_booking_property_id` - Property-booking relationships
- `idx_booking_user_id` - User-booking relationships
- `idx_review_property_id` - Property-review relationships
- `idx_payment_booking_id` - Booking-payment relationships

## Notes

- These queries assume proper foreign key relationships between tables
- FULL OUTER JOIN syntax may vary depending on your SQL database system
- Always verify your database schema matches the assumed structure before executing queries
- Consider performance implications when choosing between JOINs and subqueries
- Use EXPLAIN or ANALYZE commands to understand query execution plans

## Repository Information

- **Repository**: alx-airbnb-database
- **Directory**: database-adv-script
- **Files**: joins_queries.sql, subqueries.sql, README.md