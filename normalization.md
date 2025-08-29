# 🧠 Airbnb Database Normalization Steps

## Overview

This document outlines the specific normalization steps applied to the Airbnb database schema. The goal was to reduce redundancy, enforce data integrity, and ensure scalability. The schema adheres to the first three normal forms (1NF, 2NF, 3NF).

---

## 1️⃣ First Normal Form (1NF)

**Objective:** Ensure atomicity and eliminate repeating groups.

### Actions Taken:
- All attributes contain atomic values (e.g., `first_name`, `email`, `pricepernight`).
- No multi-valued fields (e.g., phone numbers are stored as single values).
- Each table has a primary key to uniquely identify rows.
- Repeating data (e.g., multiple bookings or reviews per user) is separated into distinct tables (`Booking`, `Review`).

✅ *Result:* All tables now contain atomic, non-repeating fields.

---

## 2️⃣ Second Normal Form (2NF)

**Objective:** Eliminate partial dependencies on composite keys.

### Actions Taken:
- Composite keys were avoided by using UUIDs as single-column primary keys.
- Attributes that depend only on part of a composite key were moved to separate tables.
  - Example: `host_id` in `Property` refers to `User(user_id)` rather than duplicating user details.
- Booking details (`start_date`, `end_date`, `total_price`) are stored in the `Booking` table, not in `Property` or `User`.

✅ *Result:* All non-key attributes are fully dependent on the entire primary key of their respective tables.

---

## 3️⃣ Third Normal Form (3NF)

**Objective:** Remove transitive dependencies between non-key attributes.

### Actions Taken:
- Removed derived or dependent fields:
  - `total_price` is calculated based on `pricepernight` and `duration`, but stored explicitly in `Booking` for performance.
- Attributes like `role`, `status`, and `payment_method` are stored as ENUMs to prevent dependency on other non-key fields.
- No field in any table depends on another non-key field (e.g., `email` does not determine `first_name`).

✅ *Result:* All non-key attributes depend only on the primary key and not on other non-key attributes.

---

## ✅ Summary

| Normal Form | Achieved By                                                  |
|-------------|--------------------------------------------------------------|
| 1NF         | Atomic fields, unique rows, no repeating groups              |
| 2NF         | Single-column primary keys, separating dependent attributes |
| 3NF         | Eliminating transitive dependencies                          |

---

## 📌 Notes

- The schema is optimized for transactional integrity.
- ENUMs are used to enforce controlled vocabularies.
- UUIDs ensure global uniqueness across distributed systems.
- Foreign keys maintain referential integrity between entities.
