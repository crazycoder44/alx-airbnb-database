# 📘 Airbnb Clone – Database Requirements

## Overview

This document outlines the database requirements for the Airbnb Clone project. The schema is designed to support core functionalities such as user management, property listings, bookings, payments, reviews, and messaging. It adheres to relational database best practices and is normalized up to Third Normal Form (3NF).

---

## 🧱 Entities and Attributes

### 1. User

Stores account and profile information for all users.

- `user_id`: UUID, Primary Key, Indexed
- `first_name`: VARCHAR, Required
- `last_name`: VARCHAR, Required
- `email`: VARCHAR, Unique, Required
- `password_hash`: VARCHAR, Required
- `phone_number`: VARCHAR, Optional
- `role`: ENUM('guest', 'host', 'admin'), Required
- `created_at`: TIMESTAMP, Defaults to current timestamp

### 2. Property

Represents listings created by hosts.

- `property_id`: UUID, Primary Key, Indexed
- `host_id`: UUID, Foreign Key → `User(user_id)`
- `name`: VARCHAR, Required
- `description`: TEXT, Required
- `location`: VARCHAR, Required
- `pricepernight`: DECIMAL, Required
- `created_at`: TIMESTAMP, Defaults to current timestamp
- `updated_at`: TIMESTAMP, Auto-updated on modification

### 3. Booking

Tracks reservations made by guests.

- `booking_id`: UUID, Primary Key, Indexed
- `property_id`: UUID, Foreign Key → `Property(property_id)`
- `user_id`: UUID, Foreign Key → `User(user_id)`
- `start_date`: DATE, Required
- `end_date`: DATE, Required
- `total_price`: DECIMAL, Required
- `status`: ENUM('pending', 'confirmed', 'canceled'), Required
- `created_at`: TIMESTAMP, Defaults to current timestamp

### 4. Payment

Records payment transactions for bookings.

- `payment_id`: UUID, Primary Key, Indexed
- `booking_id`: UUID, Foreign Key → `Booking(booking_id)`
- `amount`: DECIMAL, Required
- `payment_date`: TIMESTAMP, Defaults to current timestamp
- `payment_method`: ENUM('credit_card', 'paypal', 'stripe'), Required

### 5. Review

Captures user feedback on properties.

- `review_id`: UUID, Primary Key, Indexed
- `property_id`: UUID, Foreign Key → `Property(property_id)`
- `user_id`: UUID, Foreign Key → `User(user_id)`
- `rating`: INTEGER, Required, Must be between 1 and 5
- `comment`: TEXT, Required
- `created_at`: TIMESTAMP, Defaults to current timestamp

### 6. Message

Enables communication between users.

- `message_id`: UUID, Primary Key, Indexed
- `sender_id`: UUID, Foreign Key → `User(user_id)`
- `recipient_id`: UUID, Foreign Key → `User(user_id)`
- `message_body`: TEXT, Required
- `sent_at`: TIMESTAMP, Defaults to current timestamp

---

## 🔐 Constraints

### User Table
- Unique constraint on `email`
- Non-null constraints on required fields

### Property Table
- Foreign key constraint on `host_id`
- Non-null constraints on essential attributes

### Booking Table
- Foreign key constraints on `property_id` and `user_id`
- `status` must be one of: `pending`, `confirmed`, `canceled`

### Payment Table
- Foreign key constraint on `booking_id`
- Ensures payment is linked to a valid booking

### Review Table
- `rating` must be between 1 and 5
- Foreign key constraints on `property_id` and `user_id`

### Message Table
- Foreign key constraints on `sender_id` and `recipient_id`

---

## ⚙️ Indexing Strategy

Primary keys are indexed automatically. Additional indexes are created to optimize query performance:

| Table     | Indexed Columns                  |
|-----------|----------------------------------|
| User      | `email`                          |
| Property  | `property_id`                    |
| Booking   | `property_id`, `booking_id`      |
| Payment   | `booking_id`                     |

---


## 📌 Notes

- UUIDs are used for all primary keys to ensure global uniqueness.
- ENUMs are used for controlled fields like `role`, `status`, and `payment_method`.
- Timestamps are automatically managed for auditability.
- The schema is compatible with relational databases such as PostgreSQL and MySQL.

---
