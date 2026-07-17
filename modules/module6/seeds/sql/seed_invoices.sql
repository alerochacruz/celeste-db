INSERT INTO invoices
(
    booking_id,
    flight_instance_id,
    base_fare,
    taxes,
    extras,
    status,
    issue_date,
    payment_date
)
SELECT
    b.id,
    b.flight_instance_id,
    amounts.base_fare,
    amounts.total_amount - amounts.base_fare,
    0,
    'PAID',
    b.booking_date,
    DATEADD(MINUTE, 5, b.booking_date)
FROM bookings b
INNER JOIN booking_statuses bs
    ON bs.id = b.status_id
CROSS APPLY
(
    SELECT CAST(COALESCE(b.total_amount, TRY_CAST(ss.setting_value AS DECIMAL(10,2)) * 1.15) AS DECIMAL(10,2)) AS total_amount
    FROM system_settings ss
    WHERE ss.setting_key = 'DEFAULT_BASE_FARE'
) totals
CROSS APPLY
(
    SELECT CAST(ROUND(totals.total_amount / 1.15, 2) AS DECIMAL(10,2)) AS base_fare,
           totals.total_amount
) amounts
WHERE bs.code = 'CONFIRMED'
  AND NOT EXISTS
  (
      SELECT 1
      FROM invoices i
      WHERE i.booking_id = b.id
  );
