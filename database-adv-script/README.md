# SQL Joins Queries

This directory contains SQL queries demonstrating different types of joins for the ALX Airbnb Database project.

## Objective

Master SQL joins by writing complex queries using different types of joins to retrieve data from multiple related tables.

## Files

- `joins_queries.sql` - Contains all SQL join queries
- `README.md` - This documentation file

## Database Schema

The queries work with the following main tables:
- **User**: Contains user information (user_id, first_name, last_name, email)
- **Booking**: Contains booking details (booking_id, user_id, start_date, end_date, total_price, status)
- **Property**: Contains property information (property_id, name, location)
- **Review**: Contains review data (review_id, property_id, rating, comment, created_at)

## Query Types Implemented

### 1. INNER JOIN Query

**Purpose**: Retrieve all bookings and the respective users who made those bookings.

**Query**: Joins the `Booking` and `User` tables to show only bookings that have matching users.

**Returns**: 
- Booking details (booking_id, start_date, end_date, total_price, status)
- User details (user_id, first_name, last_name, email)

**Use Case**: When you need to see booking information along with complete user details, excluding any orphaned bookings.

### 2. LEFT JOIN Query

**Purpose**: Retrieve all properties and their reviews, including properties that have no reviews.

**Query**: Joins the `Property` and `Review` tables, keeping all properties even if they don't have reviews.

**Returns**:
- Property details (property_id, name, location)
- Review details (review_id, rating, comment, created_at) where available
- NULL values for review fields when no reviews exist

**Use Case**: When you need a complete list of all properties, regardless of whether they have been reviewed or not.

### 3. FULL OUTER JOIN Query

**Purpose**: Retrieve all users and all bookings, even if the user has no booking or a booking is not linked to a user.

**Query**: Joins the `User` and `Booking` tables, showing all records from both tables regardless of matching criteria.

**Returns**:
- User details (user_id, first_name, last_name) where available
- Booking details (booking_id, start_date, end_date, status) where available
- NULL values where no match exists in either direction

**Use Case**: When you need to see all users (including those who haven't made bookings) and all bookings (including any orphaned bookings).

## Key Concepts Demonstrated

### INNER JOIN
- Only returns rows where there's a match in both tables
- Most restrictive join type
- Useful for finding relationships that definitely exist

### LEFT JOIN (LEFT OUTER JOIN)
- Returns all rows from the left table
- Includes matching rows from the right table where available
- NULL values for right table columns when no match exists
- Useful for "show me everything from table A, plus related data from table B if it exists"

### FULL OUTER JOIN
- Returns all rows from both tables
- Shows matches where they exist
- Shows non-matching rows from both sides with NULL values
- Most comprehensive join type
- Useful for complete data analysis including orphaned records

## Usage Instructions

1. Ensure you have access to the ALX Airbnb database
2. Run the queries in `joins_queries.sql` in your SQL environment
3. Each query can be executed independently
4. Review the results to understand how different join types affect the output

## Expected Results

- **INNER JOIN**: Only bookings with valid users
- **LEFT JOIN**: All properties, with review data where it exists
- **FULL OUTER JOIN**: Complete view of users and bookings relationship

## Notes

- These queries assume proper foreign key relationships between tables
- FULL OUTER JOIN syntax may vary depending on your SQL database system
- Always verify your database schema matches the assumed structure before executing queries

## Repository Information

- **Repository**: alx-airbnb-database
- **Directory**: database-adv-script
- **Files**: joins_queries.sql, README.md