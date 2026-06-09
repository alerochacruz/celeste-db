INSERT INTO bookings ([BOOKING_CODE], [BOOKER_PASSENGER_ID], [FLIGHT_INSTANCE_ID], [STATUS_ID], [BOOKING_DATE], [TOTAL_AMOUNT]) VALUES
  ('LAO1A001', 1,  1, 2, '2026-02-15 14:30:00',  450.00),  -- Martín reserva familiar (3 pax) - CONFIRMED
  ('LAO1B002', 4,  1, 2, '2026-02-20 10:15:00',  150.00),  -- Sofia individual mismo vuelo - CONFIRMED
  ('LAO2A003', 5,  2, 2, '2026-02-18 09:00:00',  180.00),  -- João - CONFIRMED
  ('LAO3A004', 6,  3, 1, '2026-02-25 16:45:00',  220.00),  -- Emma - PENDING
  ('LAO4A005', 7,  4, 2, '2026-02-22 11:30:00',  300.00),  -- Pierre business - CONFIRMED
  ('LAO5A006', 8,  5, 3, '2026-02-10 08:20:00',  175.00),  -- Camila - CANCELLED
  ('LAO6A007', 9,  6, 2, '2026-02-28 13:50:00',  195.00),  -- Yuki - CONFIRMED
  ('LAO7A008', 10, 7, 4, '2026-02-05 17:10:00',  160.00),  -- Liam - NO_SHOW
  ('LAO8A009', 11, 8, 2, '2026-03-01 12:00:00',  140.00),  -- Mateo - CONFIRMED
  ('LAO9A010', 12, 9, 2, '2026-03-02 15:25:00',  500.00);  -- Anna business - CONFIRMED