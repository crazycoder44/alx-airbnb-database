# 📦 Airbnb Clone Database Schema

## Overview

This repository contains the SQL schema definition for an Airbnb-style booking platform. The schema is designed to support core functionalities such as user management, property listings, bookings, payments, reviews, and messaging between users. It follows best practices in relational database design, including normalization up to Third Normal Form (3NF), and includes indexing for performance optimization.

---

## 🧱 Schema Structure

The database consists of six main entities:

1. **User** – Stores user account details and roles.
2. **Property** – Represents listings created by hosts.
3. **Booking** – Tracks reservations made by guests.
4. **Payment** – Records payment transactions for bookings.
5. **Review** – Captures user feedback on properties.
6. **Message** – Enables communication between users.

---

## 📄 Table Definitions

### 1. `User`

Stores personal and account information for all users.

- **Primary Key**: `user_id`
- **Constraints**: Unique email, non-null fields
- **Indexes**: `email` for login performance

### 2. `Property`

Represents a rental listing hosted by a user.

- **Primary Key**: `property_id`
- **Foreign Key**: `host_id` → `User(user_id)`
- **Constraints**: Non-null attributes, automatic timestamps
- **Indexes**: `host_id`, `property_id`

### 3. `Booking`

Tracks reservations made by users for properties.

- **Primary Key**: `booking_id`
- **Foreign Keys**: `property_id` → `Property(property_id)`, `user_id` → `User(user_id)`
- **Constraints**: Valid status ENUM, non-null dates and price
- **Indexes**: `property_id`, `user_id`

### 4. `Payment`

Records payments made for bookings.

- **Primary Key**: `payment_id`
- **Foreign Key**: `booking_id` → `Booking(booking_id)`
- **Constraints**: Unique booking reference, valid payment method ENUM
- **Indexes**: `booking_id`

### 5. `Review`

Captures user ratings and comments for properties.

- **Primary Key**: `review_id`
- **Foreign Keys**: `property_id`, `user_id`
- **Constraints**: Rating must be between 1 and 5

### 6. `Message`

Enables direct messaging between users.

- **Primary Key**: `message_id`
- **Foreign Keys**: `sender_id`, `recipient_id`
- **Constraints**: Non-null message body and timestamps

---

## ⚙️ Performance Optimization

The schema includes strategic indexing to improve query performance:

| Table     | Indexed Columns                  |
|-----------|----------------------------------|
| User      | `email`                          |
| Property  | `host_id`, `property_id`         |
| Booking   | `property_id`, `user_id`         |
| Payment   | `booking_id`                     |

---

## 🛡️ Data Integrity & Constraints

- **Referential Integrity**: Enforced via foreign keys
- **Domain Constraints**: ENUMs for roles, statuses, and payment methods
- **Validation**: Rating range enforced via `CHECK` constraint
- **Timestamps**: Automatically managed for creation and updates

---

## 🚀 Getting Started

To deploy the schema:

1. Ensure your database supports UUIDs and ENUMs (e.g., PostgreSQL or MySQL).
2. Run the SQL scripts in the provided order to create tables and indexes.
3. Seed data can be added manually or via migration tools.

---

## 📬 Contact

For questions, suggestions, or contributions, please reach out to the project maintainer.

---
