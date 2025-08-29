# 🌍 Airbnb Clone – Sample Data Seeder

## Purpose

This `seed.sql` file populates the Airbnb Clone database with realistic sample data to support development, testing, and demonstration. It includes multiple users, properties, bookings, payments, reviews, and messages to simulate real-world usage.

---

## 📂 Directory Structure

**Repository**: `alx-airbnb-database`  
**Directory**: `database-script-0x02`  
**Files**:
- `seed.sql`: SQL script to insert sample data
- `README.md`: Documentation for the seed script

---

## 🧪 Sample Data Overview

### 👤 Users
- Hosts and guests with valid emails and roles
- Includes phone numbers and timestamps

### 🏠 Properties
- Listings with descriptions, locations, and pricing
- Linked to host users

### 📅 Bookings
- Reservations with start/end dates and total price
- Includes various statuses (confirmed, pending)

### 💳 Payments
- Linked to confirmed bookings
- Includes payment method and timestamp

### ⭐ Reviews
- Ratings between 1–5 with comments
- Linked to properties and guests

### 💬 Messages
- Simulates guest-host communication
- Includes timestamps and message bodies

---

## 🚀 Usage

To seed the database:

1. Ensure the schema is already created (`CREATE TABLE` statements executed).
2. Run the `seed.sql` script using your SQL client or migration tool.

```bash
psql -U your_user -d your_database -f seed.sql