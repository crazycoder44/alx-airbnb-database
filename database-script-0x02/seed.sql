-- Sample Users
INSERT INTO User (user_id, first_name, last_name, email, password_hash, phone_number, role, created_at)
VALUES
  ('a1e1f1d0-1111-4a1b-9a1c-111111111111', 'Alice', 'Johnson', 'alice@example.com', 'hashed_pw_1', '08012345678', 'host', CURRENT_TIMESTAMP),
  ('b2e2f2d0-2222-4b2b-9b2c-222222222222', 'Bob', 'Smith', 'bob@example.com', 'hashed_pw_2', '08023456789', 'guest', CURRENT_TIMESTAMP),
  ('c3e3f3d0-3333-4c3b-9c3c-333333333333', 'Carol', 'Lee', 'carol@example.com', 'hashed_pw_3', NULL, 'guest', CURRENT_TIMESTAMP);

-- Sample Properties
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight, created_at, updated_at)
VALUES
  ('p1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'a1e1f1d0-1111-4a1b-9a1c-111111111111', 'Cozy Loft', 'A modern loft in downtown Lagos.', 'Lagos, Nigeria', 150.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('p2e2f2d0-bbbb-4b2b-9b2c-bbbbbbb22222', 'a1e1f1d0-1111-4a1b-9a1c-111111111111', 'Beachside Bungalow', 'Relax by the sea in this charming bungalow.', 'Lekki, Nigeria', 200.00, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Sample Bookings
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status, created_at)
VALUES
  ('bk1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'p1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'b2e2f2d0-2222-4b2b-9b2c-222222222222', '2025-09-01', '2025-09-05', 600.00, 'confirmed', CURRENT_TIMESTAMP),
  ('bk2e2f2d0-bbbb-4b2b-9b2c-bbbbbbb22222', 'p2e2f2d0-bbbb-4b2b-9b2c-bbbbbbb22222', 'c3e3f3d0-3333-4c3b-9c3c-333333333333', '2025-09-10', '2025-09-12', 400.00, 'pending', CURRENT_TIMESTAMP);

-- Sample Payments
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, payment_method)
VALUES
  ('pay1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'bk1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 600.00, CURRENT_TIMESTAMP, 'credit_card');

-- Sample Reviews
INSERT INTO Review (review_id, property_id, user_id, rating, comment, created_at)
VALUES
  ('rev1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'p1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'b2e2f2d0-2222-4b2b-9b2c-222222222222', 5, 'Amazing stay! Super clean and well located.', CURRENT_TIMESTAMP);

-- Sample Messages
INSERT INTO Message (message_id, sender_id, recipient_id, message_body, sent_at)
VALUES
  ('msg1e1f1d0-aaaa-4a1b-9a1c-aaaaaaa11111', 'b2e2f2d0-2222-4b2b-9b2c-222222222222', 'a1e1f1d0-1111-4a1b-9a1c-111111111111', 'Hi Alice, is your loft available next weekend?', CURRENT_TIMESTAMP),
  ('msg2e2f2d0-bbbb-4b2b-9b2c-bbbbbbb22222', 'a1e1f1d0-1111-4a1b-9a1c-111111111111', 'b2e2f2d0-2222-4b2b-9b2c-222222222222', 'Yes, it is! Feel free to book anytime.', CURRENT_TIMESTAMP);