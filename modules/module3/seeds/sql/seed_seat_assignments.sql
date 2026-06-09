INSERT INTO seat_assignments ([PASSENGER_ID], [BOOKING_ID], [FLIGHT_INSTANCE_ID], [SEAT_NUMBER], [CLASS], [ASSIGNED_AT]) VALUES
  -- Booking 1: familia Rodríguez en flight_instance 1 (3 asientos juntos)
  (1,  1,  1, '12A', 'ECONOMY', '2026-02-15 14:35:00'),  -- Martín
  (2,  1,  1, '12B', 'ECONOMY', '2026-02-15 14:35:00'),  -- Lucía
  (3,  1,  1, '12C', 'ECONOMY', '2026-02-15 14:35:00'),  -- Tomás (hijo)

  -- Booking 2: Sofia, mismo vuelo distinto asiento
  (4,  2,  1, '14A', 'ECONOMY', '2026-02-20 10:20:00'),

  -- Booking 3: João
  (5,  3,  2, '8C',  'ECONOMY', '2026-02-18 09:05:00'),

  -- Booking 4: Emma (PENDING, igual tiene asiento tentativo)
  (6,  4,  3, '15F', 'ECONOMY', '2026-02-25 16:50:00'),

  -- Booking 5: Pierre en business
  (7,  5,  4, '2A',  'BUSINESS', '2026-02-22 11:35:00'),

  -- Booking 6: Camila — cancelada, igual quedó el asiento histórico
  (8,  6,  5, '18D', 'ECONOMY', '2026-02-10 08:25:00'),

  -- Booking 7: Yuki
  (9,  7,  6, '11B', 'ECONOMY', '2026-02-28 13:55:00'),

  -- Booking 8: Liam — no_show, también tuvo asiento
  (10, 8,  7, '20C', 'ECONOMY', '2026-02-05 17:15:00'),

  -- Booking 9: Mateo
  (11, 9,  8, '9A',  'ECONOMY', '2026-03-01 12:05:00'),

  -- Booking 10: Anna en business
  (12, 10, 9, '1F',  'BUSINESS', '2026-03-02 15:30:00');