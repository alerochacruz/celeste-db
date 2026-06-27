-- Check-ins de ejemplo basados en bookings CONFIRMED de M3
-- booking 1  → Martín  (passenger 1),  flight 1, seat 1  (12A ECONOMY)  → BOARDED
-- booking 2  → Sofia   (passenger 4),  flight 1, seat 2  (14A ECONOMY)  → NO_SHOW
-- booking 3  → Joao    (passenger 5),  flight 2, seat 3  (8C  ECONOMY)  → BOARDED
-- booking 5  → Pierre  (passenger 7),  flight 4, seat 5  (2A  BUSINESS) → BOARDED
-- booking 7  → Yuki    (passenger 9),  flight 6, seat 6  (11B ECONOMY)  → CHECKED_IN
-- booking 9  → Mateo   (passenger 11), flight 8, seat 7  (9A  ECONOMY)  → BOARDED
-- booking 10 → Anna    (passenger 12), flight 9, seat 8  (1F  BUSINESS) → BOARDED

INSERT INTO check_ins (
    booking_id, flight_instance_id, passenger_id,
    seat_assignment_id, boarding_group_id,
    checked_in_at, channel, boarding_pass_code, status
)
VALUES
    (1,  1, 1,  1, 2,  '2026-03-15 05:30:00', 'COUNTER', 'BP-MARTIN01', 'BOARDED'),
    (2,  1, 4,  2, 2,  '2026-03-15 05:45:00', 'WEB',     'BP-SOFIA002', 'NO_SHOW'),
    (3,  2, 5,  3, 4,  '2026-03-15 08:30:00', 'APP',     'BP-JOAO0003', 'BOARDED'),
    (5,  4, 7,  5, 5,  '2026-03-16 07:40:00', 'COUNTER', 'BP-PIERRE05', 'BOARDED'),
    (7,  6, 9,  6, 8,  '2026-03-17 09:40:00', 'KIOSK',   'BP-YUKI0007', 'CHECKED_IN'),
    (9,  8, 11, 7, 9,  '2026-03-18 08:40:00', 'WEB',     'BP-MATEO009', 'BOARDED'),
    (10, 9, 12, 8, 11, '2026-03-19 10:40:00', 'COUNTER', 'BP-ANNA0010', 'BOARDED');
